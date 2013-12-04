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

		model.usingType(EfanRenderer#)
		model.usingType(EfanRenderCtx#)
		model.usingType(ComponentCtx#)
		model.usingType(RenderBufStack#)
		model.extendMixin(EfanLibrary#)

//		model.addField(ComponentCache#, "componentCache").addFacet(Inject#)
		model.addField(EfanLibraryHelper#, "libraryHelper").addFacet(Inject#)

		model.overrideField(EfanLibrary#name, "\"${libName}\"", "throw Err(\"'name' is read only.\")")

		// add render methods
		componentFinder.findComponentTypes(pod).each |comType| {	
			log.debug("  - found component ${comType.name}")

			initMethod	:= componentMeta.initMethod(comType)
			initSig 	:= componentMeta.initMethodSig(comType, "|Obj?|? bodyFunc := null")
			
			args := initMethod != null ? initMethod.params.join(",") { it.name } : "," 
			body := "args := [${args}]\n"
			body += "return libraryHelper.render(\"${libName}\", ${comType.qname}#, args, bodyFunc)\n"
			
//			initMethod	:= componentMeta.initMethod(comType)
//			body := "component := (${comType.qname}) componentCache.getOrMake(\"${libName}\", ${comType.qname}#)\n"
//			
//			body += "rendered := RenderBufStack.push() |StrBuf renderBuf -> StrBuf| {\n"
//			
//			body += "\tEfanRenderCtx.renderEfan(renderBuf, (EfanRenderer) component, (|->|?) bodyFunc) |->| {\n"
//			// relax, the push is more of a pop
//			body += "\t\tComponentCtx.push\n"
//			if (initMethod != null) 
//				body += "\t\tcomponent.initialise(" + (initMethod?.params?.join(", ") { it.name } ?: "") + ")\n"
//			body += "\t\t((EfanRenderer) component)._af_render(null)\n"
//			body += "\t}\n"
//			body += "\treturn renderBuf\n"
//			
//			body += "}\n"
//
//			body += "return (RenderBufStack.peek(false) == null) ? rendered.toStr : Str.defVal\n"

			model.addMethod(Str#, "render" + comType.name.capitalize, initSig, body)
		}

//		Env.cur.err.printLine(model.toFantomCode)
		return plasticCompiler.compileModel(model)
	}
}
