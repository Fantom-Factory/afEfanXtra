using afConcurrent
using afIoc

** (Service) - What you contribute your `TemplateFinder` to.
@NoDoc
const mixin TemplateFinders {

	** Finds a (cached) TemplateSource for the given component type.
	abstract TemplateSource getOrFindTemplate(Type componentType)
	
}

internal const class TemplateFindersImpl : TemplateFinders {

	@Inject	private const TemplateConverters	templateConverters
			private const TemplateFinder[] 		finders
			private const AtomicMap				typeToSrc	:= AtomicMap() { it.keyType = Type#; it.valType = TemplateSource# }

	new make(TemplateFinder[] finders, |This|in) { 
		in(this) 
		this.finders = finders.toImmutable
	}
	
	override TemplateSource getOrFindTemplate(Type componentType) {
		typeToSrc.getOrAdd(componentType) |->TemplateSource| {			
			templateSrc := finders.eachWhile { it.findTemplate(componentType) }
			if (templateSrc != null)
				return templateSrc
			
			templates := finders.reduce(Uri[,]) |Uri[] all, finder -> Uri[]| { all.addAll(finder.templates(componentType)) }
			throw NotFoundErr(ErrMsgs.componentTemplateNotFound(componentType), templates)
		}
	}
}
