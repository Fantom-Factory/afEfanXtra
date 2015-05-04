using afPlastic
using afIoc
using afEfan

** (Service) -  
@NoDoc
const mixin ComponentCompiler {
	abstract EfanComponent compile(Type componentType, TemplateSource templateSource)
}

internal const class ComponentCompilerImpl : ComponentCompiler {

	@Inject	private const ComponentMeta					componentMeta
	@Inject	private const EfanLibraries					efanLibraries
	@Inject	private const Registry						registry
	@Inject	private const DependencyProviders			dependencyProviders
	@Inject private const EfanEngine 					efanEngine
			private const |Type, PlasticClassModel|[]	compilerCallbacks
	static	private const Type[]						allowedReturnTypes 	:= [Void#, Bool#]
			private const Type:ServiceScope				serviceScopes

	new make(|Type, PlasticClassModel|[] compilerCallbacks, |This|in) { 
		in(this) 
		this.compilerCallbacks = compilerCallbacks
		
		scopes := [:]
		registry.serviceDefinitions.each { scopes[it.serviceType] = it.serviceScope }
		this.serviceScopes = scopes
	}

	override EfanComponent compile(Type comType, TemplateSource templateSrc) {
		init := componentMeta.findMethod(comType, InitRender#)
		if (!allowedReturnTypes.any {(init?.returns ?: Void#).fits(it)} )
			throw EfanErr(ErrMsgs.componentCompilerWrongReturnType(init, allowedReturnTypes))

		before := componentMeta.findMethod(comType, BeforeRender#)
		if (!allowedReturnTypes.any {(before?.returns ?: Void#).fits(it)} )
			throw EfanErr(ErrMsgs.componentCompilerWrongReturnType(before, allowedReturnTypes))

		after := componentMeta.findMethod(comType, AfterRender#)
		if (!allowedReturnTypes.any {(after?.returns ?: Void#).fits(it)} )
			throw EfanErr(ErrMsgs.componentCompilerWrongReturnType(after, allowedReturnTypes))

		model := PlasticClassModel("${comType.name}Impl", true)
		model.extend(comType)
		
		// use the component's pod - it's expected behaviour as you think of the component as being in the same pod
		// (and not in some plastic generated-on-the-fly pod!)
		model.usingPod(comType.pod)

		model.addField(EfanTemplateMeta#, "_efan_templateMeta")
		model.overrideField(EfanComponent#templateMeta, "_efan_templateMeta", """throw Err("templateMeta is read only.")""")
		
		// create ctor for afIoc to instantiate	
		// todo: add @Inject to ctor to ensure afIoc calls it - actually don't. Then other libs can add it to their ctors 
		model.addCtor("makeWithIoc", "${EfanTemplateMeta#.qname} templateMeta, |This|in", "in(this)\nthis._efan_templateMeta = templateMeta")

		model.addField(ComponentRenderer#,	"_efan_renderer" ).addFacet(Inject#)
		model.addField(ComponentCtxMgr#,	"_efan_comCtxMgr").addFacet(Inject#)

		// inject libraries
		efanLibraries.all.each |lib| {
			model.addField(lib.typeof, lib.name).addFacet(Inject#, ["id":lib.name.toCode])			
		}

		// give callbacks a chance to add to our model
		compilerCallbacks.each { it.call(comType, model) }
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

			injectionCtx := InjectionCtx.makeFromField(null, field) { it.targetType = field.parent }
			if (dependencyProviders.canProvideDependency(injectionCtx)) {
				// Have calls to threaded / non-const services / dependency provided objs call through to the registry, 
				// so they're not actually held in the efan component. 
				if (serviceScopes[field.type] != ServiceScope.perApplication) {
					regRequired = true
					// we can't just declare a normal '_efan_comCtxMgr.peek' var, copy the facets over and let IoC inject the dependency
					// because when the type gets autobuild, there is no render ctx on the thread
					model.overrideField(field, 
						"if (_efan_comCtxMgr.peek.hasVariable(${field.qname.toCode})) {
						 	return _efan_comCtxMgr.peek.getVariable(${field.qname.toCode})
						 }
						 injectCtx := afIoc::InjectionCtx.makeFromField(this, Field.findField(${field.qname.toCode}));
						 var := _efan_dependencyProviders.provideDependency(injectCtx, true)
						 _efan_comCtxMgr.peek.setVariable(${field.qname.toCode}, var)
						 return var", 
						"_efan_comCtxMgr.peek.setVariable(${field.qname.toCode}, it)"
					)
					return
				}

				if (serviceScopes[field.type] == ServiceScope.perApplication) {
					// Inject all other services into the field. It looks nicer! 
					injectFieldName := "_ioc_${field.name}"
					// need to copy facets to field in subclass - see http://fantom.org/sidewalk/topic/2186#c14112
					newField := model.addField(field.type, injectFieldName)
					field.facets.each { newField.addFacetClone(it) }
					model.overrideField(field, injectFieldName, """throw Err("You can not set @Inject'ed fields: ${field.qname}")""")
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
			newField := model.addField(DependencyProviders#, "_efan_dependencyProviders")
			newField.addFacet(Inject#)
		}
		
		try {
			classModel 	 := efanEngine.parseTemplateIntoModel(templateSrc.location, templateSrc.template, model)
			efanMetaData := efanEngine.compileModel(templateSrc.location, templateSrc.template, model)
			libName 	 := efanLibraries.findFor(comType).name
			myEfanMeta	 := efanMetaData.clone([EfanTemplateMeta#templateId : "${libName}::${comType.name}"])
			return registry.autobuild(myEfanMeta.type, [myEfanMeta])
			
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
