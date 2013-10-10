using afIoc::Inject
using afIoc::Registry
using afPlastic
using afEfan::EfanCompiler
using afEfan::EfanRenderer
using afEfan::EfanMetaData

@NoDoc
const mixin ComponentCompiler {
	
	abstract EfanRenderer compile(Type comType, File efanFile)
}

internal const class ComponentCompilerImpl : ComponentCompiler {

	@Inject	private const EfanLibraries			efanLibraries
	@Inject	private const TemplateConverters	templateConverters
	@Inject	private const Registry				registry
	@Inject private const EfanCompiler 			efanCompiler
	
	new make(|This|in) { in(this) }

	override EfanRenderer compile(Type comType, File efanFile) {
		model := PlasticClassModel("${comType.name}Impl", true)
		model.extendMixin(comType)

		// create ctor for afIoc to instantiate	
		// TODO: add @Inject to make sure
		model.addCtor("makeWithIoc", "${EfanMetaData#.qname} efanMeta, |This|in", "in(this)\nthis._af_efanMetaData = efanMeta")
		
		// add 3rd party component libraries
		efanLibraries.libraries.each |type, name| {
			model.addField(type.typeof, name, null, null, [Inject#])
		}

		model.addField(ComponentHelper#, "_af_componentHelper", null, null, [Inject#])

		// implement abstract fields
		comType.fields.each |field| {
			
			if (field.isStatic)
				return

			if (field.parent == EfanRenderer#)
				return

			// TODO: copy values for all other facets
			if (field.hasFacet(Inject#)) {
				injectFieldName := "_af_inject${field.name.capitalize}"
				// @see http://fantom.org/sidewalk/topic/2186#c14112
				model.addField(field.type, injectFieldName, null, null, field.facets.map { it.typeof })
				model.overrideField(field, injectFieldName, """throw Err("You can not set @Inject'ed fields: ${field.qname}")""")
//				model.overrideField(field, "_af_componentHelper.service(${field.type.qname}#)", """throw Err("You can not set @Inject'ed fields: ${field.qname}")""")
				return
			}

			// TODO: copy all facets
			// normal render variables
			model.overrideField(field, """_af_componentHelper.getVariable("${field.name}")""", """_af_componentHelper.setVariable("${field.name}", it)""")
		}

		efanSrc 	:= templateConverters.convertTemplate(efanFile)
		
		renderer	:= efanCompiler.compileWithModel(efanFile.normalize.uri, efanSrc, null, model) |Type efanType, EfanMetaData efanMeta -> EfanRenderer| {
			registry.autobuild(efanType, [efanMeta])
		}
		
		return renderer
	}
	
}
