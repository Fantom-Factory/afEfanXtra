using afIoc::Inject

const mixin EfanTemplateFinder {

	** Return an EfanTemplateSource
	abstract File? findTemplate(Type componentType)

}

internal const class FindEfanByTypeName : EfanTemplateFinder {
	
	@Inject	private const EfanTemplateConverters	templateConverters

	new make(|This|in) { in(this) }
	
	override File? findTemplate(Type componentType) {
		templateConverters.files(componentType.pod).find |file->Bool| {
			index 		:= file.name.index(".")
			fileName	:= file.name[0..<index].lower
			pageName	:= componentType.name.lower
			if (fileName == pageName)
				return true

			// TODO: Maybe have a TemplateSuffixes service
			if (pageName.endsWith("page") && fileName == pageName[0..<-4])
				return true
			
			return false
		}
	}
}

internal const class FindEfanByFacetValue : EfanTemplateFinder {
	override File? findTemplate(Type componentType) {
		null
	}
}
