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
			return initRet == false ? "" : doRenderLoop(component)
		}
	}

	** Used by Pillow
	Str doRenderLoop(EfanComponent component) {
		renderBuf	:= StrBuf()
		renderLoop	:= true
		while (renderLoop) {

			b4Ret := componentMeta.callMethod(BeforeRender#, component, [renderBuf])
			
			if (b4Ret != false) {
				// render the efan template, or whatever the user returns
				rendered := component.renderTemplate()
				renderBuf.add(rendered)
			}

			aftRet := componentMeta.callMethod(AfterRender#, component, [renderBuf])

			renderLoop = (aftRet == false)
		}
		
		return renderBuf.toStr
	}

	internal Str renderBody(EfanComponent component) {
		peek	:= EfanRenderCtx.peek
		bodyCtx := peek.bodyDup
		
		return bodyCtx == null ? ""
			: bodyCtx.runInCtx |ctx| {
				peek.bodyFunc?.call(ctx)
				return ctx.renderBuf.toStr
			}
	}
}
