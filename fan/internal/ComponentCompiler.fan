using afPlastic::PlasticCompiler
using afPlastic::PlasticClassModel
using afIoc::Inject
using afIoc::InjectionCtx
using afIoc::Registry
using afIoc::DependencyProviders
using afEfan::EfanErr
using afEfan::EfanMeta
using afEfan::EfanParser
using afEfan::EfanCompiler
using afEfan::EfanCompilationErr

** (Service) -  
@NoDoc
const mixin ComponentCompiler {
	abstract EfanMeta compile(Type comType, TemplateSource templateSource)
}

internal const class ComponentCompilerImpl : ComponentCompiler {
	@Inject	private const EfanLibraries					efanLibraries
	@Inject private const EfanCompiler					efanCompiler

	new make(|This| f) { f(this) }

	override EfanMeta compile(Type comType, TemplateSource templateSrc) {
		
		try {
			return efanCompiler.compile(templateSrc.location, templateSrc.template, null, [comType])
			
		} catch (EfanCompilationErr err) {
			// try to help the user with silly typos and mistakes
			regex	:= Regex.fromStr("(?i)^Unknown method '.+\\.render(.+)'\$")			
			matcher := regex.matcher(err.msg)
			if (!matcher.matches)  
				throw err

			comName := matcher.group(1)			
			actualComType := (Type?) efanLibraries.all.eachWhile |lib| {
				lib.componentTypes.find { it.name.equalsIgnoreCase(comName) }
			} ?: throw err
			
			lib := efanLibraries.findFor(actualComType)
			throw err.withXtraMsg("\n  ALIEN-AID: Did you mean: ${lib.name}.render${actualComType.name}(...) ???")
		}
	}
}

internal const class CompilerCallback {
	static	private const Type[]						allowedReturnTypes 	:= [Void#, Bool#]

	@Inject	private const EfanParser					efanParser
	@Inject	private const ComponentMeta					componentMeta
	@Inject	private const EfanLibraries					efanLibraries
	@Inject	private const Registry						registry
	@Inject	private const DependencyProviders			dependencyProviders

	new make(|This| f) { f(this) }

	Void callback(Type comType, PlasticClassModel model) {
		init := componentMeta.findMethod(comType, InitRender#)
		// allow @InitRender to return anything, mainly for Pillow so it can return BedSheet Response Objs
//		if (!allowedReturnTypes.any {(init?.returns ?: Void#).fits(it)} )
//			throw EfanErr(ErrMsgs.componentCompilerWrongReturnType(init, allowedReturnTypes))

		before := componentMeta.findMethod(comType, BeforeRender#)
		if (!allowedReturnTypes.any {(before?.returns ?: Void#).fits(it)} )
			throw EfanErr(msgWrongReturnType(before, allowedReturnTypes))

		after := componentMeta.findMethod(comType, AfterRender#)
		if (!allowedReturnTypes.any {(after?.returns ?: Void#).fits(it)} )
			throw EfanErr(msgWrongReturnType(after, allowedReturnTypes))

		libName 	 := efanLibraries.findFor(comType).name
		componentId	 := "${libName}::${comType.name}"


		renderCtx := EfanRenderCtx#peek.qname
		fieldName := efanParser.fieldName
		model.fields.removeAll(model.fields.findAll { it.name.startsWith(fieldName) })
		model.addField(Obj?#,	 fieldName, """${renderCtx}.renderBuf.toStr""", """${renderCtx}.renderBuf.add(it)""")

		
		// use the component's pod - it's expected behaviour as you think of the component as being in the same pod
		// (and not in some plastic generated-on-the-fly pod!)
		model.usingPod(comType.pod)

		model.addField(EfanMeta#,			"_efan_templateMeta")
		model.addField(Str#,				"_efan_componentId"	).withInitValue(componentId.toCode) { it.isConst = true }
		model.addField(ComponentRenderer#,	"_efan_renderer"	).addFacet(Inject#)
		
		// create ctor for afIoc to instantiate	
		model.ctors.clear	// ours should be the only one that gets called
		itBlock		:= model.superClass.methods.find { it.isCtor && it.params.size == 1 && it.params.first.type.fits(Func#) }
		ctorSuper	:= itBlock == null ? null : "super.${itBlock.name}(in)"
		ctorBody	:= itBlock == null ? "in(this)\n" : ""
		model.addCtor("makeWithIoc", "${EfanMeta#.qname} efanMeta, |This| in", "${ctorBody}this._efan_templateMeta = efanMeta", ctorSuper)
		
		// inject libraries
		efanLibraries.all.each |lib| {
			model.addField(lib.typeof, lib.name).addFacet(Inject#, ["id":lib.name.toCode])
		}

		
		// implement abstract fields - but don't bother for normal classes
		if (comType.isConst || comType.isMixin)
			overrideAbstractFields(comType, model)
	}

	Void overrideAbstractFields(Type comType, PlasticClassModel model) {
		regRequired := false
		comType.fields.each |field| {
			if (field.isStatic)
				return

			// check if field already catered for by a callback
			if (model.hasField(field.name))
				return

			// ignore fields defined in 'the system' hierarchy
			if (field.parent == EfanComponent#)
				return
			
			// ignore fields we can't override
			if (!field.isAbstract && !field.isVirtual)
				return

			// implement normal fields (from non-const mixins)
			if (!model.isConst) {
				model.overrideField(field)
				return
			}
			
			renderCtx := EfanRenderCtx#peek.qname
			injectCtx := InjectionCtxImpl {
				it.field			= field
				it.targetType		= field.parent
			}
			if (field.isAbstract && dependencyProviders.canProvide(registry.activeScope, injectCtx)) {
				serviceDef := registry.serviceDefs.find { it.matchesType(field.type) }

				// do simplier injection for root services 'cos it looks better and is easier to debug  
				if (serviceDef != null && serviceDef.matchedScopes.containsAny("builtin root".split)) {
					// annoyingly, fields *can not* be overridden in const classes with a storage field
					// but we can override and redirect to another field
					
					injectFieldName := "_ioc_${field.name}"
					newField := model.addField(field.type, injectFieldName)
					
					// copy over @Inject to ensure *this* newField gets injected
					field.facets.each { newField.addFacetClone(it) }					
					model.overrideField(field, injectFieldName, "")	// ignore this setter, as it gets called by IoC
					return
				}

				// Have calls to threaded / non-const services / dependency provided objs call through to the registry, 
				// so they're not actually held in the efan component. 
				else {
					regRequired = true
					// when the class is built and the field values injected, there's no render ctx on the thread
					// so we dynamically retrieve the dependency on 'get' - and stash it
					model.overrideField(field, 
						"if (${renderCtx}.hasVar(${field.qname.toCode}))
						 	return ${renderCtx}.getVar(${field.qname.toCode})
						 field     := Field.findField(${field.qname.toCode})
						 injectCtx := afEfanXtra::InjectionCtxImpl { it.field = field; it.targetType = field.parent; it.targetInstance = this }
						 var       := _efan_dependencyProviders.provide(_efan_registry.activeScope, injectCtx, true)
						 ${renderCtx}.setVar(${field.qname.toCode}, var)
						 return var", 
						// we can't stop IoC from injecting values when the class is built - so just ignore the setter
						""
					)
					return
				}
			}

			if (!model.hasField(field.name)) {
				newField := model.overrideField(field, "${renderCtx}.getVar(${field.qname.toCode})", "${renderCtx}.setVar(${field.qname.toCode}, it)")
				// need to copy facets to field in subclass - see http://fantom.org/sidewalk/topic/2186#c14112
				field.facets.each { newField.addFacetClone(it) }
			}
		}

		if (regRequired) {
			model.addField(DependencyProviders#, "_efan_dependencyProviders").addFacet(Inject#)
			model.addField(Registry#, "_efan_registry").addFacet(Inject#)
		}
	}
	
	private static Str msgWrongReturnType(Method method, Type[] allowedReturnTypes) {
		"Method '${method.returns.name} ${method.qname}' should return one of " + allowedReturnTypes.join(", ") { it.name }.replace("sys::", "")
	}
}

@NoDoc
class InjectionCtxImpl : InjectionCtx {
	override Str?		serviceId
	override Obj?		targetInstance
	override Type?		targetType
	override Field?		field
	override Func?		func
	override Obj?[]?	funcArgs
	override Param?		funcParam
	override Int?		funcParamIndex
}
