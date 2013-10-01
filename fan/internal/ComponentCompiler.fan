using afIoc::Inject
using afPlastic
using afEfan::EfanCompiler
using afEfan::EfanRenderer

const class ComponentCompiler {

	@Inject	private const EfanLibraries			efanLibraries
	@Inject	private const EfanCompiler 			efanCompiler
	@Inject	private const TemplateConverters	templateConverters
	
	new make(|This|in) { in(this) }
	
	Type compile(Type comType, File efanFile) {
		
		model := PlasticClassModel("${comType.name}Impl", true)
		model.extendMixin(comType)

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
			
			if (field.hasFacet(Inject#)) {
				injectFieldName := "_af_inject${field.name.capitalize}"
				// @see http://fantom.org/sidewalk/topic/2186#c14112
				model.addField(field.type, injectFieldName, null, null, field.facets.map { it.typeof })
				model.overrideField(field, injectFieldName, """throw Err("You can not set @Inject'ed fields: ${field.qname}")""")
//				model.overrideField(field, "_af_componentHelper.service(${field.type.qname}#)", """throw Err("You can not set @Inject'ed fields: ${field.qname}")""")
				return
			}

			// normal render variables
			model.overrideField(field, """_af_componentHelper.getVariable("${field.name}")""", """_af_componentHelper.setVariable("${field.name}", it)""")
		}

		efanSrc 	:= templateConverters.convertTemplate(efanFile)
		
		implType	:= efanCompiler.compileWithModel(efanFile.normalize.uri, efanSrc, null, model)
		
		return implType
	}
	
}
