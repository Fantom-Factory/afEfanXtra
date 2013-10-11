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

	override Type compileLibrary(Str prefix, Pod pod) {
		log.debug("Compiling Component Library '${prefix}' for ${pod.name}")
		model := PlasticClassModel("${prefix.capitalize}EfanLibrary", true)

		model.usingType(EfanRenderer#)
		model.usingType(EfanRenderCtx#)
		model.extendMixin(EfanLibrary#)
		
		// TODO: stick in plastic?
//		model.overrideField(EfanLibrary#componentCache, null, null, [Inject#])
		// @see http://fantom.org/sidewalk/topic/2186#c14112
		injectFieldName := "_af_injectComponentCache"
		model.addField(ComponentCache#, injectFieldName, null, null, [Inject#])
		model.overrideField(EfanLibrary#componentCache, injectFieldName, """throw Err("You can not set @Inject'ed fields: ${EfanLibrary#componentCache.qname}")""")

		// add render methods
		componentFinder.findComponentTypes(pod).each |comType| {	
			log.debug("  - found component ${comType.name}")
			
			// FIXME: why do we not just return void?
			initMethod	:= componentMeta.initMethod(comType)
			initSig 	:= componentMeta.initMethodSig(comType, "|EfanRenderer obj|? bodyFunc := null")

			body 	:= "component := (${comType.qname}) componentCache.getOrMake(${comType.qname}#)\n"
			body 	+= "component->_af_componentHelper->scopeVariables() |->| {\n"

			// TODO: make init more robust
			if (initMethod != null)
				body += "  component.initialise(" + (initMethod?.params?.join(", ") { it.name } ?: "") + ")\n"

			body += "  EfanRenderCtx.render.efan((EfanRenderer) component, null, bodyFunc)\n"
			body += "}\n"
			body += "return component"
			
			model.addMethod(comType, "render" + comType.name.capitalize, initSig, body)
		}

//		Env.cur.err.printLine(model.toFantomCode)
		return plasticCompiler.compileModel(model)
	}
}
