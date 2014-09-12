using afEfan

** Implement to define an 'efanXtra' component.
** 
** Whereas 'efan' has 'EfanRenderer' instances, 'efanXtra' has 'EfanComponent' instances. 
const mixin EfanComponent {

	** Meta data about the compiled efan templates
	abstract EfanTemplateMeta templateMeta

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
		((ComponentRenderer)(this -> _efan_renderer)).render(this, initArgs, bodyFunc)
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
		((ComponentRenderer)(this -> _efan_renderer)).renderBody(this)
	}
	
	** Renders the efan template. Not meant to be invoked by you, the user!
	** 
	** Override to bypass template rendering and return your own generated content.
	** Useful for simple components.  
	virtual Str renderTemplate() {
		this -> _efan_render()
		return Str.defVal
	}

	** Returns 'efanTemplateMeta.templateId()'
	@NoDoc
	override Str toStr() { templateMeta.templateId }
}
