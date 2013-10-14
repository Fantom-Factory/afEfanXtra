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
	
	@Inject private	const PlasticCompiler	plasticCompiler
	@Inject private	const ComponentFinder	componentFinder
	@Inject private	const ComponentMeta		componentMeta
	
	new make(|This| in) { in(this) }

	override Type compileLibrary(Str libName, Pod pod) {
		log.debug("Compiling Component Library '${libName}' for ${pod.name}")
		model := PlasticClassModel("${libName.capitalize}EfanLibrary", true)

		model.usingType(EfanRenderer#)
		model.usingType(EfanRenderCtx#)
		model.extendMixin(EfanLibrary#)
		
		model.addField(ComponentCache#, "componentCache", null, null, [Inject#])

		// add render methods
		componentFinder.findComponentTypes(pod).each |comType| {	
			log.debug("  - found component ${comType.name}")
			
			initMethod	:= componentMeta.initMethod(comType)
			initSig 	:= componentMeta.initMethodSig(comType, "|EfanRenderer obj|? bodyFunc := null")
			
			body := "try {\n"
			if (initMethod != null) {
				body += "\tcomponent := (${comType.qname}) componentCache.getOrMake(\"${libName}\", ${comType.qname}#)\n"
				body += "\tafEfanExtra::ComponentCtx.withScope((EfanRenderer) component) |->| {\n"
				body += "\t\tcomponent.initialise(" + (initMethod?.params?.join(", ") { it.name } ?: "") + ")\n"
				body += "\t}\n"
			}
			body += "\treturn ((EfanRenderer) component).render(null, bodyFunc)\n"
			body += "} finally { \n"
			body += "\tafEfanExtra::ComponentCtx.cleanUp();\n"
			body += "}\n"

			model.addMethod(Str#, "render" + comType.name.capitalize, initSig, body)
		}

//		Env.cur.err.printLine(model.toFantomCode)
		return plasticCompiler.compileModel(model)
	}
}
