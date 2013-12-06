using afEfan::EfanRenderCtx
using afEfan::EfanMetaData

@NoDoc
const mixin EfanComponent {

	** Meta data about the compiled efan templates
	abstract EfanMetaData efanMetaData

	** Renders the body of the enclosing efan template. Example, a simple 'layout.html' may be 
	** defined as: 
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

	** Returns efanMetaData.templateId()
	override Str toStr() { efanMetaData.templateId }
}
