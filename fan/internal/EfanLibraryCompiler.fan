using afIoc::Inject
using afPlastic::PlasticCompiler
using afPlastic::PlasticClassModel
using afEfan::EfanRenderer
using afEfan::EfanRenderCtx

@NoDoc
const mixin EfanLibraryCompiler {
	abstract Type compileLibrary(Str prefix, Pod pod)
}

internal const class EfanLibraryCompilerImpl : EfanLibraryCompiler {
	private const static Log log := Utils.getLog(EfanLibraries#)
	
	@Inject private	const PlasticCompiler	plasticCompiler
	@Inject private	const ComponentFinder	componentFinder
	@Inject private	const ComponentMeta		componentMeta
	
	new make(|This| in) { in(this) }

	override Type compileLibrary(Str libName, Pod pod) {
		log.debug("Compiling Component Library '${libName}' for ${pod.name}")
		model := PlasticClassModel("${libName.capitalize}EfanLibrary", true)

		model.extendMixin(EfanLibrary#)

		inject(model, EfanLibrary#componentCache)
		inject(model, EfanLibrary#componentMeta)

		model.overrideField(EfanLibrary#name, "\"${libName}\"", "throw Err(\"'name' is read only.\")")

		// add render methods
		componentFinder.findComponentTypes(pod).each |comType| {	
			log.debug("  - found component ${comType.name}")

			initMethod	:= componentMeta.findMethod(comType, InitRender#)
			initSig 	:= componentMeta.methodSig(comType, InitRender#, "|Obj?|? bodyFunc := null")
			
			args := (initMethod != null && !initMethod.params.isEmpty) ? (initMethod.params.join(",") { it.name }) : "," 
			body := "args := [${args}]\n"
			body += "return renderComponent(${comType.qname}#, args, bodyFunc)\n"
			
			model.addMethod(Str#, "render" + comType.name.capitalize, initSig, body)
		}

//		Env.cur.err.printLine(model.toFantomCode)
		return plasticCompiler.compileModel(model)
	}
	
	private Void inject(PlasticClassModel model, Field field) {
		injectFieldName := "_af_inject${field.name.capitalize}"
		newField := model.addField(field.type, injectFieldName)
		field.facets.each { newField.addFacetClone(it) }
		model.overrideField(field, injectFieldName, """throw Err("You can not set @Inject'ed fields: ${field.qname}")""")
	}
}