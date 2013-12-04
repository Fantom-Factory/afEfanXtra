using afEfan::EfanRenderCtx
using afEfan::EfanRenderer
using concurrent::Actor

@NoDoc
const mixin EfanComponent : EfanRenderer {

	override Str render(Obj? ctx, |Obj?|? bodyFunc := null) {
		throw Err("Strictly not allowed!")
	}

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
	override Str renderBody() {
		EfanRenderCtx.renderBody(RenderBufStack.peek)
		return Str.defVal
	}
}
