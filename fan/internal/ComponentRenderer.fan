using afIoc
using afEfan

** This is here just to keep EfanComponent tidy, really.
@NoDoc
const class ComponentRenderer {
	
	@Inject private const ComponentCtxMgr	componentCtxMgr
	@Inject private const ComponentMeta		componentMeta
	
	new make(|This|in) { in(this) }

	Str runInCtx(EfanComponent component, |->Obj?| func) {
		return EfanRenderer.renderComponent(component, null) |->Obj?| {
			componentCtxMgr.createNew
			return func.call
		}
	}
	
	Str render(EfanComponent component, Obj?[]? initArgs := null, |->|? bodyFunc := null) {
		return EfanRenderer.renderComponent(component, bodyFunc) |->| {
			componentCtxMgr.createNew
			
			initRet := componentMeta.callMethod(InitRender#, component, initArgs ?: Obj#.emptyList)

			// if initRender() returns false, cut rendering short
			if (initRet != false)
				doRenderLoop(component)
		}
	}

	Void doRenderLoop(EfanComponent component) {
		renderBuf	:= EfanRenderer.peek.renderBuf
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
	}

	Str renderBody(EfanComponent component) {
		EfanRenderer.renderBody
	}
}

