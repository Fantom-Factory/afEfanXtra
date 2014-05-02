using afConcurrent
using afIoc
using afPlastic::PlasticClassModel
using afEfan::EfanRenderer
using afIocConfig::Config

** Lazy cache of efan components.
@NoDoc
const mixin ComponentCache {

	abstract EfanComponent getOrMake(Str libName, Type componentType)

}

internal const class ComponentCacheImpl : ComponentCache {

	@Config { id="afEfan.templateTimeout" }
	@Inject	private const Duration 				templateTimeout
	@Inject	private const EfanTemplateFinders	templateFinders
	@Inject	private const ComponentCompiler		compiler
			private const AtomicMap 			typeToFile
			private const SynchronizedFileMap	fileToComponent

	new make(ActorPools actorPools, |This|in) { 
		in(this) 
		typeToFile		= AtomicMap()
		fileToComponent	= SynchronizedFileMap(actorPools["afEfanXtra.fileCache"], templateTimeout)
	}

	override EfanComponent getOrMake(Str libName, Type componentType) {
		
		templateFile := typeToFile.getOrAdd(componentType) {
			templateFinders.findTemplate(componentType)
		}
		
		component := fileToComponent.getOrAddOrUpdate(templateFile) {
			compiler.compile(libName, componentType, templateFile)
		}

		return component
	}
}

