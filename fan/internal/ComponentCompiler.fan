using afIoc::Inject
using afIoc::Registry
using afIoc::ServiceStats
using afIoc::ServiceStat
using afIoc::ServiceScope
using afPlastic
using afEfan::EfanCompiler
using afEfan::EfanErr
using afEfan::EfanMetaData
using afEfan::EfanCompilationErr

** (Service) -  
@NoDoc
const mixin ComponentCompiler {
	abstract EfanComponent compile(Type componentType, TemplateSource templateSource)
}

internal const class ComponentCompilerImpl : ComponentCompiler {

	@Inject	private const ComponentMeta					componentMeta
	@Inject	private const EfanXtra						efanXtra
	@Inject	private const EfanLibraries					efanLibraries
	@Inject	private const Registry						registry
	@Inject private const EfanCompiler 					efanCompiler
	@Inject private const ServiceStats					serviceStats
			private const |Type, PlasticClassModel|[]	compilerCallbacks
	static	private const Type[]						allowedReturnTypes 	:= [Void#, Bool#]
			private const Type:ServiceScope				serviceScopes

	new make(|Type, PlasticClassModel|[] compilerCallbacks, |This|in) { 
		in(this) 
		this.compilerCallbacks = compilerCallbacks
		
		scopes := [:]
		serviceStats.stats.each { scopes[it.serviceType] = it.scope }
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

		model.addField(EfanMetaData#, "_efan_metaData")
		model.overrideField(EfanComponent#efanMetaData, "_efan_metaData", """throw Err("efanMetaData is read only.")""")
		
		// create ctor for afIoc to instantiate	
		// todo: add @Inject to ctor to ensure afIoc calls it - actually don't. Then other libs can add it to their ctors 
		model.addCtor("makeWithIoc", "${EfanMetaData#.qname} efanMeta, |This|in", "in(this)\nthis._efan_metaData = efanMeta")

		// inject libraries
		efanXtra.libraries.each |lib| {
			model.addField(lib.typeof, lib.name, null, null).addFacet(Inject#)			
		}

		// give callbacks a chance to add to our model
		compilerCallbacks.each { it.call(comType, model) }
		regRequired := false
		
		// implement abstract fields
		comType.fields.each |field| {
			if (field.isStatic)
				return

			// ignore fields defined in 'the system' hierarchy
			if (field.parent == EfanComponent#)
				return

			if (field.hasFacet(Inject#)) {
				// Have calls to threaded / non-const services call through to the registry, so they're not actually 
				// held in the efan component. This'll work for 95% of use cases where the service can be identified
				// solely by service type...
				if (serviceScopes[field.type] == ServiceScope.perThread) {
					regRequired = true
					model.overrideField(field, """_af_registry.dependencyByType(${field.type}#)""", """throw Err("You can not set @Inject'ed fields: ${field.qname}")""")				
					return
				}
				// Inject all other services into the field. That way we don't loose the context, @Config, @ServiceId, 
				// Log dependency injection, etc...   
				injectFieldName := "_af_inject${field.name.capitalize}"
				// @see http://fantom.org/sidewalk/topic/2186#c14112
				newField := model.addField(field.type, injectFieldName)
				field.facets.each { newField.addFacetClone(it) }
				model.overrideField(field, injectFieldName, """throw Err("You can not set @Inject'ed fields: ${field.qname}")""")
			}

			if (!model.hasField(field.name)) {
				newField := model.overrideField(field, """afEfanXtra::ComponentCtx.peek.getVariable("${field.name}")""", """afEfanXtra::ComponentCtx.peek.setVariable("${field.name}", it)""")
				field.facets.each { newField.addFacetClone(it) }
			}
		}

		if (regRequired) {
			newField := model.addField(Registry#, "_af_registry")
			newField.addFacet(Inject#)
		}
		
		try {
			
			classModel 	 := efanCompiler.parseTemplateIntoModel(templateSrc.location, templateSrc.template, model)
			efanMetaData := efanCompiler.compileModel(templateSrc.location, templateSrc.template, model)
			libName 	 := efanLibraries.findFor(comType).name
			myEfanMeta	 := efanMetaData.clone([EfanMetaData#templateId : "${libName}::${comType.name}"])
			return registry.autobuild(myEfanMeta.type, [myEfanMeta])
			
		} catch (EfanCompilationErr err) {
			// try to help the user with silly typos and mistakes
			regex	:= Regex.fromStr("(?i)^Unknown method '.+\\.render(.+)'\$")			
			matcher := regex.matcher(err.msg)
			if (!matcher.matches)  
				throw err

			comName := matcher.group(1)			
			actualComType := (Type?) efanXtra.libraries.eachWhile |lib| {
				lib.componentTypes.find { it.name.equalsIgnoreCase(comName) }
			} ?: throw err
			
			lib := efanLibraries.findFor(actualComType)
			throw err.withXtraMsg(ErrMsgs.alienAidComponentTypo(lib.name, actualComType.name))
		}
	}
	
	private static EfanMetaData clone(EfanMetaData efanMeta, |Field:Obj?|? overridePlan := null) {
		Utils.cloneObj(efanMeta, overridePlan)
	}
}
