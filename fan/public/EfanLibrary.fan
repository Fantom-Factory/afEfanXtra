using afIoc::Inject
using afEfan

** TODO: better doc
** Holds efan components as defined in a contributed pod. 
** Contains dynamically generated methods for rendering efan components. 
** Libs are auto injected into your components 
const mixin EfanLibrary {

	** The name of library - given when you contribute a pod to 'EfanLibraries'. 
	abstract Str name
	
	@NoDoc	@Inject abstract ComponentCache	componentCache
	@NoDoc	@Inject abstract ComponentMeta	componentMeta
	
	** Renders the given efan component. If the '@InitRender' method returns anything other than Void, null or true, 
	** rendering is aborted and the value returned.
	Obj? renderComponent(Type comType, Obj?[] initArgs, |Obj?|? bodyFunc := null) {
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

	** Utility method to check if a set of parameters fit the [@InitRenderMethod]`InitRenderMethod`.
	Bool fitsInitRenderMethod(Type comType, Type[] paramTypes) {
		initMethod := componentMeta.findMethod(comType, InitRender#)
		if (initMethod == null) {
			return paramTypes.isEmpty
		}
		return ReflectUtils.paramTypesFitMethodSignature(paramTypes, initMethod)
	}	
}
