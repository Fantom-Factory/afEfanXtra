using afIoc

// Maybe make this public - rename maybe?
** (Service) - What you contribute your `TemplateFinder` to.
@NoDoc
const mixin TemplateFinders {

	// Maybe later this will return a templae source?
	** Finds an efan template for the given efan component type.
	abstract File findTemplate(Type componentType)
	
}

internal const class TemplateFindersImpl : TemplateFinders {

	@Inject	private const TemplateConverters	templateConverters
			private const TemplateFinder[] 		finders

	new make(TemplateFinder[] finders, |This|in) { 
		in(this) 
		this.finders = finders.toImmutable
	}
	
	override File findTemplate(Type componentType) {
		template := finders.eachWhile { it.findTemplate(componentType) }
		if (template != null)
			return template
		
		templates := finders.reduce(File[,]) |File[] all, finder -> File[]| { all.addAll(finder.templateFiles(componentType)) }
		throw NotFoundErr(ErrMsgs.componentTemplateNotFound(componentType), templates)
	}
}
