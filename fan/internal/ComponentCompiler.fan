using afIoc::Inject
using afIoc::Registry
using afPlastic
using afEfan::EfanCompiler
using afEfan::EfanRenderer
using afEfan::EfanMetaData
using afEfan::EfanCompilationErr

** (Service) -  
@NoDoc
const mixin ComponentCompiler {
	
	// TODO: change sig
//	abstract EfanRenderer compile(Str libName, Type comType, Str efanSrc, Uri efanSrcLoc)
	abstract EfanRenderer compile(Str libName, Type comType, File efanFile)
}

internal const class ComponentCompilerImpl : ComponentCompiler {

	@Inject	private const EfanLibraries				efanLibraries
	@Inject	private const EfanTemplateConverters	templateConverters
	@Inject	private const Registry					registry
	@Inject private const EfanCompiler 				efanCompiler
			private const |PlasticClassModel|[]		compilerCallbacks
	
	new make(|PlasticClassModel|[] compilerCallbacks, |This|in) { 
		in(this) 
		this.compilerCallbacks = compilerCallbacks
	}

	override EfanRenderer compile(Str libName, Type comType, File efanFile) {
		model := PlasticClassModel("${comType.name}Impl", true)
		model.extendMixin(comType)

		// create ctor for afIoc to instantiate	
		// todo: add @Inject to ctor to ensure afIoc calls it - actually don't. Then other libs can add it to their ctors 
		model.addCtor("makeWithIoc", "${EfanMetaData#.qname} efanMeta, |This|in", "in(this)\nthis._af_efanMetaData = efanMeta")

		// give a more human ID - helpful for debugging
		model.extendMixin(EfanRenderer#)
		
		// add 3rd party component libraries
		efanLibraries.libraries.each |type, name| {
			model.addField(type.typeof, name, null, null).addFacet(Inject#)
		}

		// give callbacks a chance to add to our model
		compilerCallbacks.each { it.call(model) }
		
		// implement abstract fields
		comType.fields.each |field| {
			
			if (field.isStatic)
				return

			if (field.parent == EfanRenderer#)
				return

			if (field.hasFacet(Inject#)) {
				injectFieldName := "_af_inject${field.name.capitalize}"
				// @see http://fantom.org/sidewalk/topic/2186#c14112
				newField := model.addField(field.type, injectFieldName)
				field.facets.each { newField.addFacetClone(it) }
				model.overrideField(field, injectFieldName, """throw Err("You can not set @Inject'ed fields: ${field.qname}")""")
//				model.overrideField(field, "_af_componentHelper.service(${field.type.qname}#)", """throw Err("You can not set @Inject'ed fields: ${field.qname}")""")
				return
			}

			if (!model.hasField(field.name)) {
				newField := model.overrideField(field, """afEfanExtra::ComponentCtx.peek.getVariable("${field.name}")""", """afEfanExtra::ComponentCtx.peek.setVariable("${field.name}", it)""")
				field.facets.each { newField.addFacetClone(it) }
			}
		}

		efanSrc 	:= templateConverters.convertTemplate(efanFile)
		
		try {
			renderer	:= efanCompiler.compileWithModel(efanFile.normalize.uri, efanSrc, null, model) |Type efanType, EfanMetaData efanMeta -> EfanRenderer| {
				myefanMeta := clone(efanMeta) |efanMeta2, plan| {
					plan[EfanMetaData#templateId] 	= "\"${libName}::${comType.name}\""
				}
				return registry.autobuild(efanType, [myefanMeta])
			}
			return renderer
			
		} catch (EfanCompilationErr err) {
			// try to help the user with silly typos and mistakes
			regex	:= Regex.fromStr("(?i)^Unknown method '.+\\.render(.+)'\$")			
			matcher := regex.matcher(err.msg)
			if (!matcher.matches)  
				throw err

			comName := matcher.group(1)
			lib := efanLibraries.libraries.keys.find |lName| {
				cName := efanLibraries.componentTypes(lName).find { it.name.equalsIgnoreCase(comName) }
				// re-assign comName to cater for case sensitivity mistakes
				if (cName != null) 
					comName = cName.name
				return (cName != null)
			}
			
			if (lib == null)
				throw err
			
			msg := ErrMsgs.alienAidComponentTypo(lib, comName)
			// TODO: EfanCompilationErr.withXtraMsg() when efan 1.3.4 is released
			linesOfPadding := (Int) EfanCompilationErr#.field("linesOfPadding").get(err)
			newErr := (Err) EfanCompilationErr#.method("make").call(err.srcCode, err.errLineNo, err.msg + msg, linesOfPadding, err.cause)
			throw newErr
		}
	}
	
	private static EfanMetaData clone(EfanMetaData efanMeta, |EfanMetaData, Field:Obj?|? overridePlan := null) {
		Utils.cloneObj(efanMeta, overridePlan)
	}
}
