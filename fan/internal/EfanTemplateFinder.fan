using afIoc::Inject
using afEfan::EfanErr

@NoDoc
const mixin EfanTemplateFinder {

	** Return an EfanTemplateSource
	abstract File? findTemplate(Type componentType)

	** Lists all possible template files - used when template could not be found 
	abstract File[] templateFiles(Type componentType)

}

internal const class FindEfanByTypeNameInPod : EfanTemplateFinder {
	
	@Inject	private const EfanTemplateConverters	templateConverters

	new make(|This|in) { in(this) }
	
	override File? findTemplate(Type componentType) {
		pageName	:= componentType.name.lower

		return templateFiles(componentType).find |file->Bool| {
			fileName	:= baseName(file)
			if (fileName == pageName)
				return true

			// TODO: Maybe have a TemplateSuffixes service - EfanTamplateMatcher.matches(Type, File)
			if (pageName.endsWith("page") && fileName == pageName[0..<-4])
				return true

			return false
		}
	}
	
	override File[] templateFiles(Type componentType) {
		componentType.pod.files.findAll { templateConverters.canConvert(it) }
	}
	
	private Str baseName(File file) {
		i := file.name.index(".")
		return file.name[0..<i].lower		
	}
}

internal const class FindEfanByTypeNameOnFileSystem : EfanTemplateFinder {
	
	@Inject	private const EfanTemplateConverters	templateConverters
	@Inject	private const EfanTemplateDirectories	templateDirectories

	new make(|This|in) { in(this) }
	
	override File? findTemplate(Type componentType) {
		pageName	:= componentType.name.lower
		
		return templateDirectories.templateDirs.eachWhile |templateDir->File?| {
			templateDir.listFiles.findAll { templateConverters.canConvert(it) }.find |file->Bool| {
				fileName	:= baseName(file)
				if (fileName == pageName)
					return true
	
				// TODO: Maybe have a TemplateSuffixes service
				if (pageName.endsWith("page") && fileName == pageName[0..<-4])
					return true
				
				return false
			}
		}		
	}

	override File[] templateFiles(Type componentType) {
		templateDirectories.templateDirs.reduce(File[,]) |File[] all, dir -> File[]| { 
			dir.listFiles.findAll { 
				templateConverters.canConvert(it)
			}
		}
	}

	private Str baseName(File file) {
		i := file.name.index(".")
		return file.name[0..<i].lower		
	}
}

internal const class FindEfanByFacetValue : EfanTemplateFinder {
	
	override File? findTemplate(Type componentType) {
		if (!componentType.hasFacet(EfanTemplate#))
			return null
		
		comFacet := (EfanTemplate) Type#.method("facet").callOn(componentType, [EfanTemplate#])	// Stoopid F4
		efanUri := comFacet.uri
		if (efanUri == null)
			return null
		
		// if absolute, it should resolve against a scheme (hopefully fan:!)
		if (efanUri.isAbs) {
			obj := comFacet.uri.get
			if (!obj.typeof.fits(File#))
				throw EfanErr(ErrMsgs.templateNotFile(efanUri, componentType, obj.typeof))
			return obj
		}
		
		// if relative, a local file maybe?
		efanFile := efanUri.toFile 
		if (efanFile.exists)
			return efanFile
		
		// last ditch attempt, look for a local pod resource
		if (efanUri.isPathAbs)
			efanUri = efanUri.toStr[1..-1].toUri
		obj := `fan://${componentType.pod}/${efanUri}`.get(null, false)
		if (obj == null)
			throw EfanErr(ErrMsgs.templateNotFound(efanUri, componentType))
		if (!obj.typeof.fits(File#))
			throw EfanErr(ErrMsgs.templateNotFile(efanUri, componentType, obj.typeof))
		return obj
	}
	
	override File[] templateFiles(Type componentType) {
		File#.emptyList
	}
}
