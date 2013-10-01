using afIoc::Inject
using afPlastic::PlasticCompiler
using afPlastic::PlasticClassModel
using afEfan::EfanRenderer
using afEfan::EfanRenderCtx

@NoDoc
const mixin LibraryCompiler {
	abstract Type compileLibrary(Str prefix, Pod pod)
	abstract Type[] findComponentTypes(Pod pod)
}

internal const class LibraryCompilerImpl : LibraryCompiler {
	private const static Log log := Utils.getLog(EfanLibraries#)
	
	private	const PlasticCompiler	plasticCompiler
	
	new make(|This| in, EfanExtraConfig efanConfig) { 
		in(this) 
		plasticCompiler = efanConfig.plasticCompiler
	}

	override Type compileLibrary(Str prefix, Pod pod) {
		log.debug("Compiling Component Library '${prefix}' for ${pod.name}")
		model := PlasticClassModel("${prefix.capitalize}EfanLibrary", true)

		model.usingType(EfanRenderer#)
		model.usingType(EfanRenderCtx#)
		model.addField(ComponentCache#, "componentCache", null, null, [Inject#])

		findComponentTypes(pod).each |com| {			
			log.debug("  - adding component ${com.name}")
			
			method	:= com.methods.find { it.name == "initialise" }
			
			initSig := (method?.params?.map { "${it.type.signature} ${it.name}" } ?: Str[,]).add("|EfanRenderer obj| bodyFunc")
			
			body := "component := (${com.qname}) componentCache.createInstance(${com.qname}#)\n"
			
			// TODO: make more robust
			if (com.method("initialise", false) != null)
				body += "component.initialise(" + (method?.params?.join(", ") { it.name } ?: "") + ")\n"

			body += "EfanRenderCtx.render.efan(component, null, bodyFunc)\n"
			body += "return component"
			
			model.addMethod(com, "render" + com.name.capitalize, initSig.join(", "), body)
		}
		
//		Env.cur.err.printLine(model.toFantomCode)
		return plasticCompiler.compileModel(model)
	}

// the rendered method
//	Layout renderLayout(Str pageTitle, |EfanRenderer obj| bodyFunc) {
//		component := (Layout) efanLibraries.create(Layout#)
//		component.initialise(pageTitle)
//		EfanRenderCtx.render.efan(component, null, bodyFunc)
//		return component
//	}	
	
	override Type[] findComponentTypes(Pod pod) {
		pod.types.findAll { it.fits(Component#) && it.isMixin && it != Component# }		
	}
}
