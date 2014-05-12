using afEfan::EfanRenderCtx
using afEfan::EfanMetaData
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
		component		:= this
		componentMeta	:= ComponentMeta()
		
		// TODO: move this into model, keep this tidy
		renderBuf	:= (StrBuf?) null
		rendered 	:= RenderBufStack.push() |StrBuf renderBufIn -> Obj?| {
			return EfanRenderCtx.renderEfan(efanMetaData, component, renderBufIn, bodyFunc) |->Obj?| {
				ComponentCtx.push

				initRet := componentMeta.callMethod(InitRender#, component, initArgs ?: Obj#.emptyList)
				
				// if init() returns false, cut rendering short
				if (initRet == false)
					return initRet

				renderLoop := true
				while (renderLoop) {

					b4Ret := componentMeta.callMethod(BeforeRender#, component, [renderBufIn])
					if (b4Ret != false) {

						// render the efan template, or whatever the user returns
						templateStr := renderTemplate()

						// if template rendering was overridden, we need to add it to the template buffer ourselves.
						if (Type.of(this).method("renderTemplate").isOverride)
							// a cheeky back door to the rendering buffer
							Type.of(this).field("_efan_output").set(this, templateStr)
					}

					aftRet := componentMeta.callMethod(AfterRender#, component, [renderBufIn])
					
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
	** Example, a simple 'layout' efan template may look like: 
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
	
	** Renders the efan template. Not meant to be invoked by you, the user!
	** 
	** Override to bypass template rendering and return your own generated content.
	** Useful for simple components.  
	virtual Str renderTemplate() {
		this -> _efan_render()
		return Str.defVal
	}

	** Returns 'efanMetaData.templateId()'
	override Str toStr() { efanMetaData.templateId }
}
