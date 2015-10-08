using afConcurrent
using afIoc
using afPlastic::PlasticClassModel
using afIocConfig::Config

** Lazy cache of efan components.
@NoDoc
const mixin ComponentCache {

	abstract EfanComponent getOrMake(Type componentType)

}

internal const class ComponentCacheImpl : ComponentCache {

	@Inject	private const TemplateFinders		templateFinders
	@Inject	private const ComponentCompiler		compiler
	@Inject	private const |->Scope|				scope
			private const SynchronizedMap		typeToComponent

	new make(ActorPools actorPools, |This|in) { 
		in(this) 
		typeToComponent	= SynchronizedMap(actorPools["afEfanXtra.caches"]) { it.keyType = Type#; it.valType = EfanComponent# }
	}

	override EfanComponent getOrMake(Type componentType) {
		templateSrc := templateFinders.getOrFindTemplate(componentType)
		activeScope	:= scope()	// need to pass the active scope into the sync'ed Actors
		component 	:= typeToComponent.getOrAdd(componentType) {
			compiler.compile(activeScope, componentType, templateSrc)
		}		

		if (templateSrc.isModified) {
			component = typeToComponent.lock.synchronized |->Obj?| {
				if (!templateSrc.isModified) {	// double lock
					templateSrc.checked			// need to update the last checked timestamp
					return null					// can't return component, it's that dodgy wrapper again!
				}
				
				templateSrc.checked
				newComponent := compiler.compile(activeScope, componentType, templateSrc)
				typeToComponent.map = typeToComponent.map.rw.set(componentType, newComponent).toImmutable
				return newComponent
			} ?: component
		}

		return component
	}
}

