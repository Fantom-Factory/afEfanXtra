using afIoc::Inject
using afPlastic::PlasticCompiler
using afPlastic::PlasticClassModel
using afEfan::EfanRenderCtx

@NoDoc
const mixin EfanLibraryCompiler {
	abstract Type compileLibrary(Str prefix, Pod pod)
}

internal const class EfanLibraryCompilerImpl : EfanLibraryCompiler {
	private const static Log log := Utils.getLog(EfanLibraryCompiler#)

	@Inject private	const PlasticCompiler	plasticCompiler
	@Inject private	const ComponentFinder	componentFinder
	@Inject private	const ComponentMeta		componentMeta

	new make(|This| in) { in(this) }

	override Type compileLibrary(Str libName, Pod pod) {
		log.debug("Compiling Component Library '${libName}' for ${pod.name}")
		model := PlasticClassModel("${libName.capitalize}EfanLibrary", true)

		model.extendMixin(EfanLibrary#)

		inject(model, EfanLibrary#componentCache)
		inject(model, EfanLibrary#componentFinder)

		model.overrideField(EfanLibrary#name, "\"${libName}\"", "throw Err(\"'name' is read only.\")")
		model.overrideField(EfanLibrary#pod,  "Pod.find(\"${pod.name}\")", "throw Err(\"'pod' is read only.\")")

		// add render methods
		componentFinder.findComponentTypes(pod).each |comType| {	
			log.debug("  - found component ${comType.name}")

			// TODO: filter out Pillow pages, as you their @PageContext means you may not be able to render them anyway
			initMethod	:= componentMeta.findMethod(comType, InitRender#)
			
			// bodyFunc is actually |->|? but for efan to make use of it-block syntax we define it as |Obj?|
			// required because the whole bodyFunc syntax is based on it!
			initSig 	:= componentMeta.methodSig (comType, InitRender#, "|Obj?|? bodyFunc := null")
			
			args := (initMethod != null && !initMethod.params.isEmpty) ? (initMethod.params.join(",") { it.name }) : "," 
			body := "args := [${args}]\n"
			// FIXME: call render directly on the component?
			body += "return _renderComponent(${comType.qname}#, args, bodyFunc)\n"
			
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
