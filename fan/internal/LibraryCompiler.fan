using afIoc::Inject
using afPlastic::PlasticCompiler
using afPlastic::PlasticClassModel
using afEfan::EfanRenderer
using afEfan::EfanRenderCtx

@NoDoc
const mixin LibraryCompiler {
	abstract Type compileLibrary(Str prefix, Pod pod)
}

internal const class LibraryCompilerImpl : LibraryCompiler {
	private const static Log log := Utils.getLog(EfanLibraries#)
	
			private	const PlasticCompiler	plasticCompiler
	@Inject private	const ComponentFinder	componentFinder
	
	new make(EfanExtraConfig efanConfig, |This| in) { 
		in(this) 
		plasticCompiler = efanConfig.plasticCompiler
	}

	override Type compileLibrary(Str prefix, Pod pod) {
		log.debug("Compiling Component Library '${prefix}' for ${pod.name}")
		model := PlasticClassModel("${prefix.capitalize}EfanLibrary", true)

		model.usingType(EfanRenderer#)
		model.usingType(EfanRenderCtx#)
		model.addField(ComponentCache#, "componentCache", null, null, [Inject#])

		componentFinder.findComponentTypes(pod).each |com| {	
			log.info("  - adding component ${com.name}")
			
			method	:= com.methods.find { it.name == "initialise" }
			
			initSig := (method?.params?.map { "${it.type.signature} ${it.name}" } ?: Str[,]).add("|EfanRenderer obj|? bodyFunc := null")
			
			body := "component := (${com.qname}) componentCache.createInstance(${com.qname}#)\n"
			
			// TODO: make more robust
			if (com.method("initialise", false) != null)
				body += "component.initialise(" + (method?.params?.join(", ") { it.name } ?: "") + ")\n"

			body += "EfanRenderCtx.render.efan((EfanRenderer) component, null, bodyFunc)\n"
			body += "return component"
			
			model.addMethod(com, "render" + com.name.capitalize, initSig.join(", "), body)
		}

//		Env.cur.err.printLine(model.toFantomCode)
		return plasticCompiler.compileModel(model)
	}
}
