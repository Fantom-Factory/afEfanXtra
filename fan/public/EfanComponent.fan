using afEfan::EfanMeta

** Implement to define an 'efanXtra' component.
** 
** Whereas 'efan' has 'EfanRenderer' instances, 'efanXtra' has 'EfanComponent' instances. 
mixin EfanComponent {

	** Meta data about the compiled efan templates
	EfanMeta efanMeta() {
		this -> _efan_templateMeta
	}

	** The main render method. 'initArgs' are passed to the '@InitRender' lifecycle method.
	** 
	** In normal use, 'bodyFunc' is only passed from within a template.
	** It is executed when 'renderBody()' is called. 
	** Use it for enclosing content in *Layout* templates. Example:
	** 
	** pre>
	** ...
	** <%= app.renderLayout() { %>
	**   ... my body content ...
	** <% } %>
	** ...
	** <pre
	Str render(Obj?[]? initArgs := null, |->|? bodyFunc := null) {
		// execute the component lifecycle
		((ComponentRenderer)(this -> _efan_renderer)).render(this, initArgs, bodyFunc)
	}

	** Call from within your template to render the body of the enclosing efan template. 
	** Example, a simple 'layout' efan template may look like: 
	** 
	** pre>
	** syntax: html
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
		// call the actual efan compiler render method
		this -> _efan_render(null)
		// FIXME !
		return ""
	}

	** Returns a unique ID for this component based on the lib and type name.
	Str componentId() {
		this -> _efan_componentId
	}

	** Returns 'componentId()'
	@NoDoc
	override Str toStr() { componentId() }
}
