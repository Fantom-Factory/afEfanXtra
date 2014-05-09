using afEfan::EfanRenderCtx
using afEfan::EfanMetaData
using afEfan::BaseEfanImpl
using afIoc

// EfanComponent will extend BaseEfanImpl. 
** Extend to define an 'efanXtra' component.
** 
** Whereas 'efan' returns 'EfanRenderer' instances, 'efanXtra' returns 'EfanComponent' instances. 
const mixin EfanComponent {

	** Meta data about the compiled efan templates
	abstract EfanMetaData efanMetaData

	** The main render method. 'initArgs' are passed to the '@InitRender' lifecycle method.
	** 
	** In normal use, 'bodyFunc' is only passed from within a template.
	** It is executed when 'renderBody()' is called. 
	** Use it for enclosing content in *Layout* templates. Example:
	** 
	** pre>
	** ...
	** <%= app.rednerLayout() { %>
	**   ... my body content ...
	** <% } %>
	** ...
	** <pre
	Str render(Obj?[]? initArgs := null, |->|? bodyFunc := null) {
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
					if (b4Ret != false) {
						
						// as this is a component, it will always be compiled (to add the library fields for starters!),
						// but we don't always need to render a template.
						userDefined := renderTemplate
						if (userDefined != Str.defVal) {
							// a cheeky back door to write to the template buffer
							Type.of(this).field("_af_code").set(this, userDefined)
						} else {
							component._af_render(null)
						}
					}
					
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
	** Example, a simple 'layout' template may look like: 
	** 
	** pre>
	** <html>
	** <body>
	**     <%= renderBody() %>
	** </body>
	** </html>
	** <pre
	Str renderBody() {
		EfanRenderCtx.renderBody(RenderBufStack.peek)
		return Str.defVal
	}
	
	virtual Str renderTemplate() {
		Str.defVal
	}

	** Returns 'efanMetaData.templateId()'
	override Str toStr() { efanMetaData.templateId }
}
