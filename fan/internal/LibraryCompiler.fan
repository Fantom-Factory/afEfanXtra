using afIoc::Inject
using afPlastic::PlasticCompiler
using afPlastic::PlasticClassModel
using afEfan::EfanRenderer
using afEfan::EfanRenderCtx

@NoDoc
const mixin LibraryCompiler {
	abstract Type compileLibrary(Str prefix, Pod pod)
	abstract Str initMethodSig(Type component)
}

internal const class LibraryCompilerImpl : LibraryCompiler {
	private const static Log log := Utils.getLog(EfanLibraries#)
	
	@Inject private	const PlasticCompiler	plasticCompiler
	@Inject private	const ComponentFinder	componentFinder
	
	new make(|This| in) { in(this) }

	override Type compileLibrary(Str prefix, Pod pod) {
		log.debug("Compiling Component Library '${prefix}' for ${pod.name}")
		model := PlasticClassModel("${prefix.capitalize}EfanLibrary", true)

		model.usingType(EfanRenderer#)
		model.usingType(EfanRenderCtx#)
		model.addField(ComponentCache#, "componentCache", null, null, [Inject#])

		// add render methods
		componentFinder.findComponentTypes(pod).each |com| {	
			log.debug("  - found component ${com.name}")
						
			initMethod	:= com.methods.find { it.name == "initialise" }
			initSig 	:= (initMethod?.params?.map { "${it.type.signature} ${it.name}" } ?: Str[,]).add("|EfanRenderer obj|? bodyFunc := null")

			body 	:= "component := (${com.qname}) componentCache.getOrMake(${com.qname}#)\n"
			body 	+= "component->_af_componentHelper->scopeVariables() |->| {\n"

			// TODO: make init more robust
			if (initMethod != null)
				body += "  component.initialise(" + (initMethod?.params?.join(", ") { it.name } ?: "") + ")\n"

			body += "  EfanRenderCtx.render.efan((EfanRenderer) component, null, bodyFunc)\n"
			body += "}\n"
			body += "return component"
			
			model.addMethod(com, "render" + com.name.capitalize, initSig.join(", "), body)
		}

//		Env.cur.err.printLine(model.toFantomCode)
		return plasticCompiler.compileModel(model)
	}
	
	override Str initMethodSig(Type component) {
		initMethod	:= component.methods.find { it.name == "initialise" }
		initSig 	:= (initMethod?.params?.map { "${it.type.signature} ${it.name}" } ?: Str[,])
		return ("render${component.name.capitalize}(" + initSig.join(", ") + ")").replace("sys::", "") 
	}
}
