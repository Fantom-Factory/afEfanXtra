using afIoc::Inject
using afEfan::EfanErr

@NoDoc
const mixin TemplateFinder {

	** Return an EfanTemplateSource
	abstract File? findTemplate(Type componentType)

	** Lists all possible template files - used when template could not be found 
	abstract File[] templateFiles(Type componentType)

}

internal const class FindEfanByTypeNameInPod : TemplateFinder {
	
	@Inject	private const TemplateConverters	templateConverters

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

internal const class FindEfanByTypeNameOnFileSystem : TemplateFinder {
	
	@Inject	private const TemplateConverters	templateConverters
	@Inject	private const TemplateDirectories	templateDirectories

	new make(|This|in) { in(this) }
	
	override File? findTemplate(Type componentType) {
		pageName	:= componentType.name.lower
		
		return templateDirectories.templateDirs.eachWhile |templateDir->File?| {
			return templateDir.listFiles.findAll { templateConverters.canConvert(it) }.find |file->Bool| {
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

@NoDoc	// used by Pillow
const class FindEfanByFacetValue : TemplateFinder {
	
	override File? findTemplate(Type componentType) {
		if (!componentType.hasFacet(EfanTemplate#))
			return null
		
		comFacet := (EfanTemplate) Type#.method("facet").callOn(componentType, [EfanTemplate#])	// Stoopid F4
		return findFile(componentType, comFacet.uri)
	}
	
	static File? findFile(Type componentType, Uri? efanUri) {
		if (efanUri == null)
			return null
		
		// if absolute, it should resolve against a scheme (hopefully fan:!)
		if (efanUri.isAbs) {
			obj := efanUri.get
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
