using afIoc
using afEfan

** This is here just to keep EfanComponent tidy, really.
@NoDoc
const class ComponentRenderer {
	
	@Inject private const ComponentCtxMgr	componentCtxMgr
	@Inject private const ComponentMeta		componentMeta
	
	new make(|This|in) { in(this) }

	// TODO at some point, I really need to clean up all this rendering stack stuff
	
	** Used by Pillow
	Obj? runInCtx(EfanComponent component, Func func) {
		EfanRenderCtx(component, null).runInCtx(func)
		
//		return EfanRenderer.renderComponent(component, null) |->Obj?| {
////			componentCtxMgr.createNew
//			return func.call
//		}
	}
	
	Str render(EfanComponent component, Obj?[]? initArgs := null, |->|? bodyFunc := null) {
		
		EfanRenderCtx(component, bodyFunc).runInCtx |ctx| {
			initRet := componentMeta.callMethod(InitRender#, component, initArgs ?: Obj#.emptyList)

			// if initRender() returns false, cut rendering short
			if (initRet != false)
				doRenderLoop(component)
			
			return ctx.renderBuf.toStr
		}
		
//		return EfanRenderer.renderComponent(component, bodyFunc) |->| {
////			componentCtxMgr.createNew
//			
//			initRet := componentMeta.callMethod(InitRender#, component, initArgs ?: Obj#.emptyList)
//
//			// if initRender() returns false, cut rendering short
//			if (initRet != false)
//				doRenderLoop(component)
//		}
	}

	** Used by Pillow
	StrBuf doRenderLoop(EfanComponent component) {
		renderBuf	:= EfanRenderCtx.peek.renderBuf
		renderLoop	:= true
		while (renderLoop) {

			b4Ret := componentMeta.callMethod(BeforeRender#, component, [renderBuf])
			
			if (b4Ret != false) {
				// render the efan template, or whatever the user returns
				templateStr := component.renderTemplate()

				renderBuf.add(templateStr)
			}

			aftRet := componentMeta.callMethod(AfterRender#, component, [renderBuf])

			renderLoop = (aftRet == false)
		}
		
		// return StrBuf for Pillow
		return renderBuf
	}

	Str renderBody(EfanComponent component) {
		echo(" body of "+component.componentId)
		dup := EfanRenderCtx.peek.parent.dup
		dup.bodyFunc = EfanRenderCtx.peek.bodyFunc
		return dup.runInCtx |ctx| {
			ctx.bodyFunc?.call(ctx)
			return ctx.renderBuf.toStr
		}
	}
}

