using afIoc::Inject
using afEfan::EfanRenderer

** Service methods for discovering and rendering efan components.
const mixin EfanExtra {

	** Returns the names of all contributed efan component libraries.
	abstract Str[]	libraries()
	
	** Returns the types of all components in the given library. A component type is a 'const mixin'
	** annotated with the '@Component' facet.
	abstract Type[]	componentTypes(Str libraryName)

	** Renders the given component. The component's 'initialise(...)' method is called with the 
	** given 'initParams'.
	abstract Str	render(Type componentType, Obj[]? initParams := null)
}

internal const class EfanExtraImpl : EfanExtra {

	@Inject	private const EfanLibraries efanLibraries
	@Inject	private const ComponentCache componentCache
	
	new make(|This|in) { in(this) }

	override Str[] libraries() {
		efanLibraries.libraries.keys.sort
	}

	override Type[] componentTypes(Str libraryName) {
		efanLibraries.componentTypes(libraryName).sort
	}

	override Str render(Type componentType, Obj[]? initParams := null) {
		efanLibraries.library(componentType).render(componentType, initParams ?: Obj#.emptyList)
	}
}
