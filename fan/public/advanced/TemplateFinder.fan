using afIoc
using afIocConfig::Config
using afEfan::EfanErr

@NoDoc
const mixin TemplateFinder {

	** Return a TemplateSource for the given component type.
	abstract TemplateSource? findTemplate(Type componentType)

	** Return the Uri of all the templates this Finder can find. 
	** Used to construct a verbose Err msg of alternative locations when a template could not be found. 
	abstract Uri[] templates(Type componentType)

}

internal const class FindEfanByTypeNameInPod : TemplateFinder {	
	@Inject	private const TemplateConverters	templateConverters
	@Inject	private const Registry				registry

	new make(|This|in) { in(this) }
	
	override TemplateSource? findTemplate(Type componentType) {
		pageName	:= componentType.name.lower

		templateUri := templates(componentType).find |file->Bool| {
			fileName	:= baseName(file)
			if (fileName == pageName)
				return true

			// TODO: Maybe have a TemplateSuffixes service - EfanTamplateMatcher.matches(Type, File)
			if (pageName.endsWith("page") && fileName == pageName[0..<-4])
				return true

			return false
		}
		return templateUri == null ? null : registry.autobuild(TemplateSourceFile#, [templateUri.get])
	}
	
	override Uri[] templates(Type componentType) {
		componentType.pod.files.findAll { templateConverters.canConvert(it) }.map { it.uri }
	}
	
	private Str baseName(Uri file) {
		i := file.name.index(".")
		return file.name[0..<i].lower		
	}
}

internal const class FindEfanByTypeNameOnFileSystem : TemplateFinder {
	@Inject	private const TemplateConverters	templateConverters
	@Inject	private const TemplateDirectories	templateDirectories
	@Inject	private const Registry				registry

	new make(|This|in) { in(this) }
	
	override TemplateSource? findTemplate(Type componentType) {
		pageName	:= componentType.name.lower
		
		templateFile := templateDirectories.templateDirs.eachWhile |templateDir->File?| {
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
		return templateFile == null ? null : registry.autobuild(TemplateSourceFile#, [templateFile])
	}

	override Uri[] templates(Type componentType) {
		(templateDirectories.templateDirs.reduce(File[,]) |File[] all, dir -> File[]| { 
			dir.listFiles.findAll { 
				templateConverters.canConvert(it)
			}
		} as File[]).map { it.uri }
	}

	private Str baseName(File file) {
		i := file.name.index(".")
		return file.name[0..<i].lower		
	}
}

@NoDoc	// used by Pillow
const class FindEfanByFacetValue : TemplateFinder {
	@Inject	private const Registry	registry

	new make(|This|in) { in(this) }
	
	override TemplateSource? findTemplate(Type componentType) {
		if (!componentType.hasFacet(TemplateLocation#))
			return null
		
		comFacet	 := (TemplateLocation) Type#.method("facet").callOn(componentType, [TemplateLocation#])	// Stoopid F4
		templateFile := findFile(componentType, comFacet.url)
		return templateFile == null ? null : registry.autobuild(TemplateSourceFile#, [templateFile])
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
	
	override Uri[] templates(Type componentType) {
		Uri#.emptyList
	}
}

internal const class FindEfanByRenderTemplateMethod : TemplateFinder {
	
	override TemplateSource? findTemplate(Type componentType) {
		componentType.method("renderTemplate").isOverride ? TemplateSourceNull(templates(componentType).first) : null
	}

	override Uri[] templates(Type componentType) {
		[`${componentType.qname}.renderTemplate`]
	}
}
