using afIoc::Inject
using afEfan

@NoDoc
const mixin EfanLibrary {

	abstract Str name
	
	@NoDoc	@Inject abstract ComponentCache	componentCache
	@NoDoc	@Inject abstract ComponentMeta	componentMeta
	
	Str renderComponent(Type comType, Obj[] initArgs, |Obj?|? bodyFunc := null) {
		component := componentCache.getOrMake(name, comType)

		Env.cur.err.printLine(component.efanMetaData.efanSrcCode)
		
		rendered := RenderBufStack.push() |StrBuf renderBuf -> StrBuf| {
			EfanRenderCtx.renderEfan(renderBuf, (EfanRenderer) component, (|->|?) bodyFunc) |->| {
				ComponentCtx.push
				
				initRet := componentMeta.callMethod(comType, InitRender#, component, initArgs)
				if (initRet == false)
					return
				
				renderLoop := true
				while (renderLoop) {
					
					b4Ret	:= componentMeta.callMethod(comType, BeforeRender#, component, [renderBuf])
					if (b4Ret == false)
						return
					
					((EfanRenderer) component)._af_render(null)
					aftRet	:= componentMeta.callMethod(comType, AfterRender#, component, [renderBuf])
					
					renderLoop = (aftRet == false)
				}
			}
			return renderBuf
		}

		// if the stack is empty, return the result of rendering
		return (RenderBufStack.peek(false) == null) ? rendered.toStr : Str.defVal
	}
}
