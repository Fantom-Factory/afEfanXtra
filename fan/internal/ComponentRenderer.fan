using afIoc
using afEfan
using afConcurrent

** This is here just to keep EfanComponent tidy, really.
const class ComponentRenderer {
	
	@Inject private const ComponentCtxMgr	componentCtxMgr
	@Inject private const ComponentMeta		componentMeta
			private const LocalRef			renderBufRef
	
	new make(ThreadLocalManager threadLocalMgr, |This|in) {
		in(this)
		this.renderBufRef = threadLocalMgr.createRef("afEfanXtra.renderBuf") |->StrBuf| { StrBuf(1024) }
	}

	Obj? runInCtx(EfanComponent component, |->Obj?| func) {
		return EfanRenderer.renderTemplate(component.templateMeta, component, renderBuf, null) |->Obj?| {
			componentCtxMgr.createNew
			return func.call
		}
	}
	
	Str render(EfanComponent component, Obj?[]? initArgs := null, |->|? bodyFunc := null) {
		rendered := EfanRenderer.renderTemplate(component.templateMeta, component, renderBuf, bodyFunc) |->Obj?| {
			componentCtxMgr.createNew
			
			initRet := componentMeta.callMethod(InitRender#, component, initArgs ?: Obj#.emptyList)

			// if initRender() returns false, cut rendering short
			return (initRet == false) ? false : doRenderLoop(component) 
		}

		// if the rendering stack is empty, return the result of rendering
		if (rendered == true && (EfanRenderingStack.peek(false) == null)) 
			return renderResult
		return Str.defVal
	}

	Bool doRenderLoop(EfanComponent component) {
		renderLoop := true
		while (renderLoop) {

			b4Ret := componentMeta.callMethod(BeforeRender#, component, [renderBuf])
			if (b4Ret != false) {

				// render the efan template, or whatever the user returns
				templateStr := component.renderTemplate()

				// if template rendering was overridden, we need to add it to the template buffer ourselves.
				if (Type.of(component).method("renderTemplate").isOverride)
					renderBuf.add(templateStr)
			}

			aftRet := componentMeta.callMethod(AfterRender#, component, [renderBuf])
			
			renderLoop = (aftRet == false)
		}

		return true
	}
	
	Str renderBody(EfanComponent component) {
		EfanRenderer.renderBody(renderBuf)
		return Str.defVal
	}

	Str renderResult() {
		result := renderBuf.toStr
		renderBufRef.cleanUp
		return result
	}
	
	private StrBuf renderBuf() {
		renderBufRef.val
	}
}

