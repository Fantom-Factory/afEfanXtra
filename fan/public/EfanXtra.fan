using afIoc::Inject
using afEfan::EfanRenderer

** (Service) - Service methods for discovering and rendering efan components.
const mixin EfanXtra {

	// FIXME: just libraries() maybe?
	
//	** Returns the names of all contributed efan component libraries.
//	abstract Str[]	libraryNames()
//
//	** Returns the efan library with the given name.
//	abstract EfanLibrary library(Str libraryName)

	** Returns the efan library that contains the given component type
//	abstract EfanLibrary findLibrary(Type componentType)
	
	abstract EfanComponent component(Type componentType)
	
	abstract EfanLibrary[] libraries()

//	** Renders the given component. 
//	** 
//	** The component's '@InitRender' method is called with the given 'initParams'. 
//	** An empty Str is returned if rendering is aborted by '@InitRender' or '@BeforeRender'.
//	abstract Str render(Type componentType, Obj?[]? initParams := null)
	
}

internal const class EfanXtraImpl : EfanXtra {

	@Inject	private const ComponentCache	componentCache
	@Inject	private const EfanLibraries 	efanLibraries
	
	new make(|This|in) { in(this) }

	override EfanComponent component(Type componentType) {
		componentCache.getOrMake(componentType)
	}
	
	override EfanLibrary[] libraries() {
		efanLibraries.all
	}
	
//	override Str[] libraryNames() {
//		efanLibraries.libraryNames
//	}
//
//	override EfanLibrary library(Str libraryName) {
//		efanLibraries.library(libraryName)
//	}
	
//	override EfanLibrary findLibrary(Type componentType) {
//		efanLibraries.find(componentType)
//	}
//	
//	override Str render(Type componentType, Obj?[]? initParams := null) {
//		findLibrary(componentType).renderComponent(componentType, initParams)
//	}
}
