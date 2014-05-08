using afConcurrent
using afIoc
using afPlastic::PlasticClassModel
using afEfan::EfanRenderer
using afIocConfig::Config

** Lazy cache of efan components.
@NoDoc
const mixin ComponentCache {

	abstract EfanComponent getOrMake(Type componentType)

}

internal const class ComponentCacheImpl : ComponentCache {

	@Inject	private const TemplateFinders		templateFinders
	@Inject	private const ComponentCompiler		compiler	
			private const SynchronizedMap		typeToComponent

	new make(ActorPools actorPools, |This|in) { 
		in(this) 
		typeToComponent	= SynchronizedMap(actorPools["afEfanXtra.componentCache"]) { it.keyType = Type#; it.valType = EfanComponent# }
	}

	override EfanComponent getOrMake(Type componentType) {
		templateSrc := templateFinders.getOrFindTemplate(componentType)
		component 	:= typeToComponent.getOrAdd(templateSrc) {
			compiler.compile(componentType, templateSrc)
		}		
		
		if (templateSrc.isModified) {
			component = typeToComponent.lock.synchronized |->Obj| {
				// double lock
				if (!templateSrc.isModified)
					return component
				
				newComponent := compiler.compile(componentType, templateSrc)
				typeToComponent.map = typeToComponent.map.rw.set(componentType, newComponent).toImmutable
				return newComponent
			}
		}

		return component
	}
}

