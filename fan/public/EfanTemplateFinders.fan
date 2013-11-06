using afIoc

** (Service) - What you contribute your `EfanTemplateFinder` to.
const mixin EfanTemplateFinders {

	** Finds an efan template for the given efan component type.
	abstract File findTemplate(Type componentType)
}

internal const class EfanTemplateFindersImpl : EfanTemplateFinders {

	@Inject	private const EfanTemplateConverters	templateConverters
			private const EfanTemplateFinder[] 		finders

	new make(EfanTemplateFinder[] finders, |This|in) { 
		in(this) 
		this.finders = finders.toImmutable
	}
	
	override File findTemplate(Type componentType) {
		finders.eachrWhile { it.findTemplate(componentType) }
		?: throw NotFoundErr(ErrMsgs.componentTemplateNotFound(componentType), templateConverters.files(componentType.pod))
	}
}
