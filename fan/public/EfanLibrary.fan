using afIoc::Inject
using afEfan

@NoDoc
const mixin EfanLibrary {

	abstract Str name
	
	@NoDoc	@Inject abstract ComponentCache	componentCache
	@NoDoc	@Inject abstract ComponentMeta	componentMeta
	
	Obj? renderComponent(Type comType, Obj[] initArgs, |Obj?|? bodyFunc := null) {
		component 	:= componentCache.getOrMake(name, comType)

		renderBuf	:= (StrBuf?) null

		rendered 	:= RenderBufStack.push() |StrBuf renderBufIn -> Obj?| {
			return EfanRenderCtx.renderEfan(renderBufIn, (BaseEfanImpl) component, (|->|?) bodyFunc) |->Obj?| {
				ComponentCtx.push

				initRet := componentMeta.callMethod(comType, InitRender#, component, initArgs)
				if (initRet != null && initRet.typeof != Bool#)
					return initRet
				
				// technically this is correct, but I'm wondering if I should return an empty Str instead???
				if (initRet == false)
					return initRet

				renderLoop := true
				while (renderLoop) {
					
					b4Ret	:= componentMeta.callMethod(comType, BeforeRender#, component, [renderBufIn])
					if (b4Ret != false)
						((BaseEfanImpl) component)._af_render(null)
					
					aftRet	:= componentMeta.callMethod(comType, AfterRender#, component, [renderBufIn])
					
					renderLoop = (aftRet == false)
				}
				
				renderBuf = renderBufIn
				return true
			}
		}

		// if the stack is empty, return the result of rendering
		if (rendered == true)
			return (RenderBufStack.peek(false) == null) ? renderBuf.toStr : Str.defVal
		return rendered
	}

	Bool fitsInitRenderMethod(Type comType, Type[] paramTypes) {
		initMethod := componentMeta.findMethod(comType, InitRender#)
		return ReflectUtils.paramTypesFitMethodSignature(paramTypes, initMethod)
	}	
}
