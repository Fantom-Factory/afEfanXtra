using afEfan::EfanRenderCtx
using afEfan::EfanMetaData
using afEfan::BaseEfanImpl
using afIoc

** Implement to define an 'efanXtra' component. 
** 
** All your templates will implicitly extend this mixin.
const mixin EfanComponent {

	** Meta data about the compiled efan templates
	abstract EfanMetaData efanMetaData

	** The library this component belongs to.
//	abstract EfanLibrary efanLibrary
	
	// FIXME: is renderBody needed? what's the relationship between this and EfanRenderer?
	Str renderTemplate(Obj?[]? initArgs := null, |->|? bodyFunc := null) {
		component		:= (BaseEfanImpl) this
		componentMeta	:= ComponentMeta()
		
		renderBuf	:= (StrBuf?) null
		rendered 	:= RenderBufStack.push() |StrBuf renderBufIn -> Obj?| {
			return EfanRenderCtx.renderEfan(renderBufIn, component, bodyFunc) |->Obj?| {
				ComponentCtx.push

				initRet := componentMeta.callMethod(InitRender#, component, initArgs ?: Obj#.emptyList)
				
				// if init() returns false, cut rendering short
				if (initRet == false)
					return initRet

				renderLoop := true
				while (renderLoop) {

					b4Ret	:= componentMeta.callMethod(BeforeRender#, component, [renderBufIn])
					if (b4Ret != false)
						component._af_render(null)
					
					aftRet	:= componentMeta.callMethod(AfterRender#, component, [renderBufIn])
					
					renderLoop = (aftRet == false)
				}
				
				renderBuf = renderBufIn
				return true
			}
		}

		// if the stack is empty, return the result of rendering
		if (rendered && (RenderBufStack.peek(false) == null))
			return renderBuf.toStr
		return Str.defVal
	}

	** Call from within your template to render the body of the enclosing efan template. 
	** Example, a simple 'layout.html' may be defined as: 
	** 
	** pre>
	** <html>
	** <head>
	**   <title><%= ctx.pageTitle %>
	** </html>
	** <body>
	**     <%= renderBody() %>
	** </html>
	** <pre
	virtual Str renderBody() {
		EfanRenderCtx.renderBody(RenderBufStack.peek)
		return Str.defVal
	}

	** Returns 'efanMetaData.templateId()'
	override Str toStr() { efanMetaData.templateId }
}
