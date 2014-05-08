using afConcurrent
using afIoc
using afPlastic::PlasticClassModel
using afEfan::EfanRenderer
using afIocConfig::Config

** Lazy cache of efan components.
@NoDoc
const mixin ComponentCache {

	// FIXME: remove libName from method -> push into compiler
	abstract EfanComponent getOrMake(Str libName, Type componentType)

}

internal const class ComponentCacheImpl : ComponentCache {

	@Config { id="afEfan.templateTimeout" }
	@Inject	private const Duration 				templateTimeout
	@Inject	private const TemplateFinders		templateFinders
	@Inject	private const ComponentCompiler		compiler
	
//			private const SynchronizedFileMap	fileToComponent

			private const SynchronizedMap		typeToComponent
			private const SynchronizedMap		typeToTemplateSrc
			private const SynchronizedFileMap	fileCache
			private const AtomicMap 			typeToFile

	new make(ActorPools actorPools, |This|in) { 
		in(this) 
		typeToFile		= AtomicMap()
//		fileToComponent	= SynchronizedFileMap(actorPools["afEfanXtra.fileCache"], templateTimeout)
		typeToComponent	= SynchronizedMap(actorPools["afEfanXtra.fileCache"])
		fileCache		= SynchronizedFileMap(actorPools["afEfanXtra.fileCache"])
	}

	override EfanComponent getOrMake(Str libName, Type componentType) {
		templateFile := typeToFile.getOrAdd(componentType) {
			templateFinders.findTemplate(componentType)
		}
		
		templateSrc := (TemplateSrc) typeToTemplateSrc.getOrAdd(componentType) {
//			TemplateSrcFactory stuff
			9
		}

		component := typeToComponent.getOrAdd(componentType) {
			compiler.compile(libName, componentType, templateFile)
		}		
		
		if (templateSrc.outOfDate) {
			typeToComponent.lock.synchronized |->Obj| {
				newCom := compiler.compile(libName, componentType, templateFile)
				typeToComponent.map = typeToComponent.map.rw.set(componentType, newCom).toImmutable
				return newCom
			}
		}

		return component
	}
}

// update TemplateFinders to return TemplateSrc, not File! Boo yakka!
//const mixin TemplateSrcFactory {
//}

const mixin TemplateSrc {
	abstract Str templateSrc()
	abstract Uri templateLoc()
	abstract Bool outOfDate()
}

const class TemplateSrcFile : TemplateSrc {
	
	private const TemplateConverters? templateConverters
//	private const TemplateFinders?	templateFinders
	
	override Str templateSrc() {
		""
	}
	override Uri templateLoc() {
		``
	}
	override Bool outOfDate() {
		true
	}
	
}
