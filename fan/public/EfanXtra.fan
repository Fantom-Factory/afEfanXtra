using afIoc
using afEfan

** (Service) - Methods for discovering efan components.
const mixin EfanXtra {
	
	** Returns the component instance for the given type.
	abstract EfanComponent component(Type componentType)
	
	** Returns all 'EfanLibrary' instances.
	abstract EfanLibrary[] libraries()

	** A hook to call a component methods within the context of the given @InitRender arguments.
	@NoDoc // exposed for Pillow
	abstract Obj? callMethod(Type comType, Obj?[] initArgs, |->Obj?| func)
	
}

internal const class EfanXtraImpl : EfanXtra {

	@Inject	private const ComponentCache	componentCache
	@Inject private const ComponentMeta		componentMeta
	@Inject	private const EfanLibraries 	efanLibraries
	
	new make(|This|in) { in(this) }

	override EfanComponent component(Type componentType) {
		componentCache.getOrMake(componentType)
	}
	
	override EfanLibrary[] libraries() {
		efanLibraries.all
	}
	
	override Obj? callMethod(Type comType, Obj?[] initArgs, |->Obj?| func) {
		component 	:= componentCache.getOrMake(comType)
		return EfanCtxStack.withCtx(component.efanMetaData.templateId) |EfanCtxStackElement element->Obj?| {
			ComponentCtx.push
			componentMeta.callMethod(InitRender#, component, initArgs)			
			return func.call
		}
	}
}
