using afIoc::Inject
using afEfan::EfanRenderCtx
using afEfan::EfanRenderer

** Methods called from EfanLibraries
@NoDoc
const class EfanLibraryHelper {

	@Inject private const ComponentCache	componentCache
	@Inject private	const ComponentMeta		componentMeta
	
	new make(|This|in) { in(this) }
	
	Str render(Str libName, Type comType, Obj[] initArgs, |Obj?|? bodyFunc) {		
		component := componentCache.getOrMake(libName, comType)

		rendered := RenderBufStack.push() |StrBuf renderBuf -> StrBuf| {
			EfanRenderCtx.renderEfan(renderBuf, (EfanRenderer) component, (|->|?) bodyFunc) |->| {
				ComponentCtx.push
				callRenderPhaseMethod(comType, component, Init#, "initialise initialize".split, initArgs)
				((EfanRenderer) component)._af_render(null)
			}
			return renderBuf
		}

		return (RenderBufStack.peek(false) == null) ? rendered.toStr : Str.defVal		
	}
	
	
	Obj? callRenderPhaseMethod(Type comType, Obj instance, Type facetType, Str[] altMethodNames, Obj[] args) {
		initMethod	:= componentMeta.initMethod(comType)
		if (initMethod == null)
			return null
		return initMethod.callOn(instance, args)
	}
}
