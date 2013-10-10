using afIoc::Inject
using afEfan::EfanRenderer

** Service methods for discovering and rendering efan components.
const mixin EfanExtra {

	** Returns the names of all contributed efan component libraries.
	abstract Str[]			libraries()
	
	** Returns the types of all components in the given library. A component type is a 'const mixin'
	** annotated with the '@Component' facet.
	** 
	** TODO: return lazy component proxies instead of types. 
	abstract Type[]			componentTypes(Str library)

	** Returns an instance of the given component type. Once created, the smae instance is always 
	** returned. Call 'render()':  
	** 
	**   Str render(Obj? ctx) 
	abstract EfanRenderer	component(Type componentType)
}

internal const class EfanExtraImpl : EfanExtra {

	@Inject	private const EfanLibraries efanLibraries
	@Inject	private const ComponentCache componentCache
	
	new make(|This|in) { in(this) }

	override Str[] libraries() {
		efanLibraries.libraries.keys.sort
	}

	override Type[] componentTypes(Str library) {
		efanLibraries.componentTypes(library).sort
	}

	override EfanRenderer component(Type componentType) {
		componentCache.getOrMake(componentType)
	}
}
