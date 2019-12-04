using afIoc
using afEfan

** This is here just to keep EfanComponent tidy, really.
@NoDoc
const class ComponentRenderer {
	
	@Inject private const ComponentMeta		componentMeta
	
	new make(|This|in) { in(this) }

	** Used by Pillow
	Obj? runInCtx(EfanComponent component, Func func) {
		EfanRenderCtx(component, null).runInCtx(func)
	}
	
	Str render(EfanComponent component, Obj?[]? initArgs := null, |->|? bodyFunc := null) {		
		EfanRenderCtx(component, bodyFunc).runInCtx |ctx| {
			initRet := componentMeta.callMethod(InitRender#, component, initArgs ?: Obj#.emptyList)

			// if initRender() returns false, cut rendering short
			if (initRet != false)
				return doRenderLoop(component).toStr
			
			return ""
//			return ctx.renderBuf.toStr
		}
	}

	** Used by Pillow
	StrBuf doRenderLoop(EfanComponent component) {
		renderBuf	:= StrBuf()
//		renderBuf	:= EfanRenderCtx.peek.renderBuf
//		rendered	:= ""
		renderLoop	:= true
		while (renderLoop) {

			b4Ret := componentMeta.callMethod(BeforeRender#, component, [renderBuf])
			
			if (b4Ret != false) {
				// render the efan template, or whatever the user returns
				rendered := component.renderTemplate()
//echo("-->"+rendered)
				renderBuf.add(rendered)
			}

			aftRet := componentMeta.callMethod(AfterRender#, component, [renderBuf])

			renderLoop = (aftRet == false)
		}
		
		// return StrBuf for Pillow
		return renderBuf
//		return StrBuf().add(rendered)
	}

	internal Str renderBody(EfanComponent component) {
		EfanRenderCtx.peek.bodyDup.runInCtx |ctx| {
			ctx.bodyFunc?.call(ctx)
			return ctx.renderBuf.toStr
		}
	}
}
