using afIoc::Inject
using afEfan

@NoDoc
const mixin EfanLibrary {

	abstract Str name
	
	@NoDoc	@Inject abstract ComponentCache	componentCache
	@NoDoc	@Inject abstract ComponentMeta	componentMeta
	
	Str renderComponent(Type componentType, Obj[] initParams) {
		methodName	:= "render${componentType.name.capitalize}"
		method		:= typeof.method(methodName)
		
		paramTypes	:= initParams.map { it.typeof }
		if (!ReflectUtils.paramTypesFitMethodSignature(paramTypes, method))
			throw Err("404 baby! TODO: better Err msg!")	// TODO: Err msg
		
		return method.callOn(this, initParams)
	}
	
	
	protected Str _af_renderComponent(Str libName, Type comType, Obj[] initArgs, |Obj?|? bodyFunc) {		
		component := componentCache.getOrMake(libName, comType)

		rendered := RenderBufStack.push() |StrBuf renderBuf -> StrBuf| {
			EfanRenderCtx.renderEfan(renderBuf, (EfanRenderer) component, (|->|?) bodyFunc) |->| {
				ComponentCtx.push
				componentMeta.callMethod(comType, InitRender#, component, initArgs)
				((EfanRenderer) component)._af_render(null)
			}
			return renderBuf
		}

		return (RenderBufStack.peek(false) == null) ? rendered.toStr : Str.defVal		
	}

}
