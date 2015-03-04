using afIoc
using afEfan

** (Service) - Methods for discovering efan components.
const mixin EfanXtra {

	** Returns all the names of contributed libraries.
	abstract Str[] libraryNames()

	** Returns an 'EfanLibrary' by contribution name.
	** 
	** Throws 'ArgErr' if not found.
	abstract EfanLibrary library(Str name)

	** Returns the component instance for the given type.
	abstract EfanComponent component(Type componentType)

	** Returns the component instance for the given type.
	** 
	** Convenience / alias for 'component(...)'.
	@Operator
	EfanComponent get(Type componentType) {
		component(componentType)
	}

	@NoDoc @Deprecated
	abstract EfanLibrary[] libraries()
}

internal const class EfanXtraImpl : EfanXtra {

	@Inject	private const ComponentCache	componentCache
	@Inject private const ComponentMeta		componentMeta
	@Inject	private const EfanLibraries 	efanLibraries
	@Inject	private const ComponentCtxMgr	comCtxMgr
	
	new make(|This|in) { in(this) }

	override EfanComponent component(Type componentType) {
		componentCache.getOrMake(componentType)
	}
	
	override EfanLibrary library(Str name) {
		efanLibraries[name]
	}

	override Str[] libraryNames() {
		efanLibraries.names
	}
	
	override EfanLibrary[] libraries() {
		efanLibraries.all
	}
}
