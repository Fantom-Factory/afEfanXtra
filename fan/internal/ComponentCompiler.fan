using afPlastic
using afIoc
using afEfan

** (Service) -  
@NoDoc
const mixin ComponentCompiler {
	abstract EfanComponent compile(Scope scope, Type comType, TemplateSource templateSource)
}

internal const class ComponentCompilerImpl : ComponentCompiler {

	@Inject	private const EfanLibraries					efanLibraries
	@Inject private const EfanCompiler					efanCompiler

	new make(|This| f) { f(this) }

	override EfanComponent compile(Scope scope, Type comType, TemplateSource templateSrc) {
		
		try {

			efanMeta	:= efanCompiler.compile(templateSrc.location, templateSrc.template, null, [comType])
			
			// FIXME we should just be returning efanMeta
//			// TODO: cache component instances somewhere else and just return type and meta 
//			// TODO: creating instances and injecting via scopes it's not going to be used in can cause problems 
//			// IoC will attempt to inject all dependencies, even if they're ignored, so we need to use the scope that the component will finally be used with
			return scope.build(efanMeta.type, [efanMeta])
			
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
			throw err.withXtraMsg(ErrMsgs.alienAidComponentTypo(lib.name, actualComType.name))
		}
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

internal const class CompilerCallback {
	static	private const Type[]						allowedReturnTypes 	:= [Void#, Bool#]

	@Inject	private const ComponentMeta					componentMeta
	@Inject	private const EfanLibraries					efanLibraries
	@Inject	private const Registry						registry
	@Inject	private const DependencyProviders			dependencyProviders

	new make(|This| f) { f(this) }

	Void callback(Type comType, PlasticClassModel model) {
		
//		model := PlasticClassModel("${comType.name}Impl", true)
//		model.extend(comType)

		init := componentMeta.findMethod(comType, InitRender#)
		// allow @InitRender to return anything, mainly for Pillow so it can return BedSheet Response Objs
//		if (!allowedReturnTypes.any {(init?.returns ?: Void#).fits(it)} )
//			throw EfanErr(ErrMsgs.componentCompilerWrongReturnType(init, allowedReturnTypes))

		before := componentMeta.findMethod(comType, BeforeRender#)
		if (!allowedReturnTypes.any {(before?.returns ?: Void#).fits(it)} )
			throw EfanErr(ErrMsgs.componentCompilerWrongReturnType(before, allowedReturnTypes))

		after := componentMeta.findMethod(comType, AfterRender#)
		if (!allowedReturnTypes.any {(after?.returns ?: Void#).fits(it)} )
			throw EfanErr(ErrMsgs.componentCompilerWrongReturnType(after, allowedReturnTypes))

		libName 	 := efanLibraries.findFor(comType).name
		componentId	 := "${libName}::${comType.name}"


		// FIXME
//		fieldName := efanParser.fieldName
		fieldName := "_efan_output"
		model.fields.removeAll(model.fields.findAll { it.name.startsWith(fieldName) })
		model.addMethod(StrBuf#, fieldName + "_val", "", "${EfanRenderer#.qname}.peek.${EfanRendererCtx#renderBuf.name}")
		model.addField(Obj?#,		fieldName, """((StrBuf) ${fieldName}_val).toStr""", """((StrBuf) ${fieldName}_val).add(it)""")

		
		// use the component's pod - it's expected behaviour as you think of the component as being in the same pod
		// (and not in some plastic generated-on-the-fly pod!)
		model.usingPod(comType.pod)

		model.addField(EfanMeta#,			"_efan_templateMeta")
		model.addField(Str#,				"_efan_componentId"	).withInitValue(componentId.toCode) { it.isConst = true }
		model.addField(ComponentRenderer#,	"_efan_renderer"	).addFacet(Inject#)
		model.addField(ComponentCtxMgr#,	"_efan_comCtxMgr"	).addFacet(Inject#)
		
		// create ctor for afIoc to instantiate	
		// todo: add @Inject to ctor to ensure afIoc calls it - actually don't. Then other libs can add it to their ctors 
		model.addCtor("makeWithIoc", "${EfanMeta#.qname} efanMeta, |This|in", "in(this)\nthis._efan_templateMeta = efanMeta")
		// TODO may need to call def super it-block ctor
		
		// inject libraries
		efanLibraries.all.each |lib| {
			model.addField(lib.typeof, lib.name).addFacet(Inject#, ["id":lib.name.toCode])
		}

		regRequired := false
		
		// implement abstract fields
		comType.fields.each |field| {
			if (field.isStatic)
				return

			// check if field already catered for by a callback
			if (model.hasField(field.name))
				return

			// ignore fields defined in 'the system' hierarchy
			if (field.parent == EfanComponent#)
				return

			injectCtx := InjectionCtxImpl {
				it.field			= field
				it.targetType		= field.parent
			}
			if (field.isAbstract && dependencyProviders.canProvide(registry.activeScope, injectCtx)) {
				serviceDef := registry.serviceDefs.find { it.matchesType(field.type) }

				// do simplier injection for root services 'cos it looks better and is easier to debug  
				if (serviceDef?.matchedScopes?.containsAny("builtin root".split) ?: false) {
					// Inject all other services into the field. It looks nicer! 
					injectFieldName := "_ioc_${field.name}"
					newField := model.addField(field.type, injectFieldName)
					
					// we can't stop IoC from injecting values when the class is built - and const fields can't be set outside of the ctor
					// so we create a new field, and inject that instead
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
						"if (_efan_comCtxMgr.peek.hasVariable(${field.qname.toCode})) {
						 	return _efan_comCtxMgr.peek.getVariable(${field.qname.toCode})
						 }
						 field     := Field.findField(${field.qname.toCode})
						 injectCtx := afEfanXtra::InjectionCtxImpl { it.field = field; it.targetType = field.parent; it.targetInstance = this }
						 var       := _efan_dependencyProviders.provide(_efan_registry.activeScope, injectCtx, true)
						 _efan_comCtxMgr.peek.setVariable(${field.qname.toCode}, var)
						 return var", 
						// we can't stop IoC from injecting values when the class is built - so just ignore the setter
						""
					)
					return
				}
			}

			if (!model.hasField(field.name)) {
				newField := model.overrideField(field, "_efan_comCtxMgr.peek.getVariable(${field.qname.toCode})", "_efan_comCtxMgr.peek.setVariable(${field.qname.toCode}, it)")
				// need to copy facets to field in subclass - see http://fantom.org/sidewalk/topic/2186#c14112
				field.facets.each { newField.addFacetClone(it) }
			}
		}

		if (regRequired) {
			model.addField(DependencyProviders#, "_efan_dependencyProviders").addFacet(Inject#)
			model.addField(Registry#, "_efan_registry").addFacet(Inject#)
		}
	}
}