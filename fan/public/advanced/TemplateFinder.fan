using afIoc::Inject
using afIoc::Scope
using afIocConfig::Config
using afEfan::EfanErr
using afConcurrent::AtomicMap
using fandoc

@NoDoc
const mixin TemplateFinder {

	** Return a TemplateSource for the given component type.
	abstract TemplateSource? findTemplate(Type componentType)

	** Return the Uris of all the templates this Finder can find. 
	** Used to construct a verbose Err msg of alternative locations when a template could not be found. 
	abstract Uri[] templates(Type componentType)
}

internal const class FindEfanByTypeNameInPod : TemplateFinder {	
	@Inject	private const TemplateConverters	templateConverters
	@Inject	private const Scope					scope
			private const AtomicMap				podFiles

	new make(|This|in) {
		in(this)
		podFiles = AtomicMap { it.keyType = Str#; it.valType = Str:File# } 
	}
	
	override TemplateSource? findTemplate(Type componentType) {
		// pop to remove sys::Obj
		templateFile := componentType.inheritance.rw { pop }.eachWhile { findTemplateFile(it) }
		return templateFile == null ? null : scope.build(TemplateSourceFile#, [templateFile])
	}
	
	override Uri[] templates(Type componentType) {
		getPodFiles(componentType.pod).vals.map { it.uri }
	}
	
	private File? findTemplateFile(Type componentType) {
		podFiles := getPodFiles(componentType.pod)
		pageName := componentType.name
		podFile	 := podFiles[pageName]

		// TODO Maybe have a TemplateSuffixes service - EfanTamplateMatcher.matches(Type, File)
		if (podFile == null && pageName.endsWith("Page")) {
			pageName = pageName[0..<-4]
			podFile	 = podFiles[pageName]
		}
		return podFile
	}
	
	** Files are keyed off their basename
	private Str:File getPodFiles(Pod pod) {
		podFiles.getOrAdd(pod.name) |->Str:File| {
			files := Str:File[:]
			pod.files.each {
				if (templateConverters.canConvert(it))
					files[baseName(it)] = it
			}
			return files
		}
	}
	
	** Needed because we take the basename of the basename,
	** .i.e. the basename of double extensions
	private static Str baseName(File file) {
		i := file.name.index(".")
		return file.name[0..<i]
	}
}

internal const class FindEfanByTypeNameOnFileSystem : TemplateFinder {
	@Inject	private const TemplateConverters	templateConverters
	@Inject	private const TemplateDirectories	templateDirectories
	@Inject	private const Scope					scope
			private const Str:File				allFiles	// files are keyed off their basename

	new make(|This|in) {
		in(this)
		allFiles  := Str:File[:]
		templateDirectories.templateDirs.each |templateDir| {
			templateDir.listFiles.each {
				if (templateConverters.canConvert(it))
					allFiles[baseName(it)] = it
			}
		}
		this.allFiles = allFiles
	}
	
	override TemplateSource? findTemplate(Type componentType) {
		// pop to remove sys::Obj
		templateFile := (File?) componentType.inheritance.rw { pop }.eachWhile { findTemplateFile(it) }
		return templateFile == null ? null : scope.build(TemplateSourceFile#, [templateFile])
	}

	override Uri[] templates(Type componentType) {
		allFiles.vals.map { it.uri }
	}

	private File? findTemplateFile(Type componentType) {
		pageName := componentType.name
		podFile	 := allFiles[pageName]

		// TODO Maybe have a TemplateSuffixes service - EfanTamplateMatcher.matches(Type, File)
		if (podFile == null && pageName.endsWith("Page")) {
			pageName = pageName[0..<-4]
			podFile	 = allFiles[pageName]
		}
		return podFile		
	}
	
	** Needed because we take the basename of the basename,
	** .i.e. the basename of double extensions
	private static Str baseName(File file) {
		i := file.name.index(".")
		return file.name[0..<i]
	}
}

@NoDoc	// used by Pillow
const class FindEfanByFacetValue : TemplateFinder {
	@Inject	private const Scope	scope

	new make(|This|in) { in(this) }
	
	override TemplateSource? findTemplate(Type componentType) {
		if (!componentType.hasFacet(TemplateLocation#))
			return null
		
		comFacet	 := (TemplateLocation) Type#.method("facet").callOn(componentType, [TemplateLocation#])	// Stoopid F4
		templateFile := findFile(componentType, comFacet.url)
		return templateFile == null ? null : scope.build(TemplateSourceFile#, [templateFile])
	}
	
	static File? findFile(Type componentType, Uri? efanUri) {
		if (efanUri == null)
			return null
		
		// if absolute, it should resolve against a scheme (hopefully fan:!)
		if (efanUri.isAbs) {
			obj := efanUri.get
			if (!obj.typeof.fits(File#))
				throw EfanErr("Template Uri `${efanUri}` for ${componentType.qname} does not resolve to a file : ${obj.typeof.qname}")
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
			throw EfanErr("Template Uri `${efanUri}` for ${componentType.qname} could not be resolved!")
		if (!obj.typeof.fits(File#))
			throw EfanErr("Template Uri `${efanUri}` for ${componentType.qname} does not resolve to a file : ${obj.typeof.qname}")
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

internal const class FindEfanByTypeFandoc : TemplateFinder {	
	@Inject	private const TemplateConverters	templateConverters
	@Inject	private const Scope					scope

	new make(|This|in) { in(this) }

	override TemplateSource? findTemplate(Type componentType) {
		fandocStr := componentType.doc
		if (fandocStr == null)
			return null
		
		temSrc := extractTemplateSource(componentType, fandocStr)
		if (temSrc != null)
			return temSrc
		
		fandocDoc := FandocParser().parseStr(fandocStr)
		return  fandocDoc.children.eachWhile |fandocNode->TemplateSource?| {
			if (fandocNode.id != DocNodeId.pre)
				return null

			docWriter := SrcDocWriter()
			((Pre) fandocNode).writeChildren(docWriter)
			templateSrc := docWriter.buf.toStr
			return extractTemplateSource(componentType, templateSrc)
		}
	}
	
	override Uri[] templates(Type componentType) {
		Uri#.emptyList
	}
	
	private TemplateSource? extractTemplateSource(Type componentType, Str templateSrc) {
		newLineIdx	:= templateSrc.index("\n") ?: -1
		firstLine	:= templateSrc[0..newLineIdx].trim
		templateUri	:= firstLine.toUri
		if (templateUri.scheme == "template") {
			ext := templateUri.pathStr.trim
			if (templateConverters.extensions.contains(ext)) {
				startIdx	:= templateSrc[newLineIdx] == '\n' ? newLineIdx + 2 : newLineIdx + 1
				templateRaw := newLineIdx == -1 ? "" : templateSrc[newLineIdx+1..-1]
				if (templateRaw.startsWith("\n"))
					templateRaw = templateRaw[1..-1]
				return scope.build(TemplateSourceStr#, [componentType, ext, templateRaw])
			}
		}
		return null
	}
}

internal class SrcDocWriter : DocWriter {
	StrBuf	buf := StrBuf()
	override Void docStart(Doc doc) 		{ }
	override Void docEnd(Doc doc)			{ }
	override Void elemStart(DocElem elem)	{ }
	override Void elemEnd(DocElem elem)		{ }
	override Void text(DocText text) {
		buf.add(text.str)
	}
}
