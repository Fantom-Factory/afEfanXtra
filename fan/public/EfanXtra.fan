using afIoc::Inject
using afEfan::EfanRenderer

** (Service) - Service methods for discovering and rendering efan components.
const mixin EfanXtra {

	** Returns the names of all contributed efan component libraries.
	abstract Str[]	libraries()
	
	** Returns the types of all components in the given library. 
	abstract Type[]	componentTypes(Str libraryName)

	** Renders the given component. 
	** 
	** The component's '@InitRender' method is called with the given 'initParams'.
	** If the '@InitRender' method returns a non-null value, then rendering is aborted and the non-null value is returned. 
	** Otherwise the rendered Str is returned. 
	abstract Obj render(Type componentType, Obj?[]? initParams := null)
	
	** Returns an instance of the component.
	abstract EfanComponent component(Type componentType)
}

internal const class EfanXtraImpl : EfanXtra {

	@Inject	private const EfanLibraries efanLibraries
	@Inject	private const ComponentCache componentCache
	
	new make(|This|in) { in(this) }

	override Str[] libraries() {
		efanLibraries.libraries.keys.sort
	}

	override Type[] componentTypes(Str libraryName) {
		efanLibraries.componentTypes(libraryName).sort
	}

	override Obj render(Type componentType, Obj?[]? initParams := null) {
		efanLibraries.library(componentType).renderComponent(componentType, initParams ?: Obj#.emptyList)
	}

	override EfanComponent component(Type componentType) {
		library := efanLibraries.library(componentType) 
		return componentCache.getOrMake(library.name, componentType)
	}
}
