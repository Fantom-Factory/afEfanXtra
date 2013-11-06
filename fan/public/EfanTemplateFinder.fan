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
		comFacet := (Component) Type#.method("facet").callOn(componentType, [Component#])	// Stoopid F4
		efanUri := comFacet.template
		if (efanUri == null)
			return null
		
		// if absolute, it should resolve against a scheme (hopefully fan:!)
		if (efanUri.isAbs)
			// TODO: Err msg if not a file
			return comFacet.template.get
		
		// if relative, a local file maybe?
		efanFile := efanUri.toFile 
		if (efanFile.exists)
			return efanFile
		
		// last ditch attempt, look for a local pod resource
		if (efanUri.isPathAbs)
			efanUri = efanUri.toStr[1..-1].toUri
		// TODO: Err msg if not found
			// TODO: Err msg if not a file
		return `fan://${componentType.pod}/${efanUri}`.get(null, false)
	}
}
