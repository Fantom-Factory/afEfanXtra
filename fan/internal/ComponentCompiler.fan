using afIoc::Inject
using afIoc::Registry
using afPlastic
using afEfan::EfanCompiler
using afEfan::EfanRenderer
using afEfan::EfanMetaData

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
		
		renderer	:= efanCompiler.compileWithModel(efanFile.normalize.uri, efanSrc, null, model) |Type efanType, EfanMetaData efanMeta -> EfanRenderer| {
			myefanMeta := clone(efanMeta) |efanMeta2, plan| {
				plan[EfanMetaData#templateId] 	= "\"${libName}::${comType.name}\""
			}
			return registry.autobuild(efanType, [myefanMeta])
		}
		
		return renderer
	}
	
	private static EfanMetaData clone(EfanMetaData efanMeta, |EfanMetaData, Field:Obj?|? overridePlan := null) {
		Utils.cloneObj(efanMeta, overridePlan)
	}
}
