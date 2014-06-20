using afIoc
using afEfan

** (Service) - Methods for discovering efan components.
const mixin EfanXtra {
	
	** Returns the component instance for the given type.
	abstract EfanComponent component(Type componentType)
	
	** Returns all 'EfanLibrary' instances.
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
	
	override EfanLibrary[] libraries() {
		efanLibraries.all
	}
}
