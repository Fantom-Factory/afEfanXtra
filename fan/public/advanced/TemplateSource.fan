using concurrent
using afIoc
using afIocConfig

@NoDoc
const mixin TemplateSource {
	
	** Returns the efan template.s
	** Should update any modified timestamps
	abstract Str template()
	
	** Uri for debug purposes
	abstract Uri location()
	
	** Should not update any internal state
	abstract Bool isModified()

	abstract DateTime lastModified()	// for sitemap	
}

@NoDoc
const class TemplateSourceFile : TemplateSource {
	@Inject	private const TemplateConverters templateConverters

	@Inject	
	@Config { id="afEfanXtra.templateTimeout" }
	private const Duration? timeout
	private const File 		templateFile
	private const AtomicRef	lastCheckedRef	:= AtomicRef()
	private const AtomicRef	lastModifiedRef	:= AtomicRef()	

	** pod files have last modified info too!
	new make(File file, |This| in) {
		in(this)
		this.templateFile			= file
		this.lastCheckedRef.val		= DateTime.now(1sec)
		this.lastModifiedRef.val	= templateFile.modified
	}
	
	override Str template() {
		templateSrc := templateFile.readAllStr
		template := templateConverters.convertTemplate(templateFile.ext, templateSrc)
		lastModifiedRef.val = templateFile.modified
		return template
	}

	override Uri location() {
		templateFile.normalize.uri
	}

	override Bool isModified() {
		now := DateTime.now(1sec)
		// cache this response for X secs to avoid hammering the file system
		if ((now - lastChecked) < timeout)
			return false

		// lastModified gets updated when we call template()
		modified := templateFile.modified > lastModified

		// if modified, then keep returning true until we re-compile the template  
		if (modified == false) lastCheckedRef.val = now
		return modified
	}

	override DateTime lastModified() {
		lastModifiedRef.val
	}

	private	DateTime lastChecked() {
		lastCheckedRef.val
	}
}

@NoDoc
const class TemplateSourceStr : TemplateSource {
	@Inject	
	private const TemplateConverters	templateConverters
	private const Type					componentType
	private const Str					src
	private const Str					ext

	new make(Type componentType, Str ext, Str src, |This| in) {
		in(this)
		this.componentType	= componentType
		this.ext			= ext
		this.src			= src
	}
	
	override Str template() {
		templateConverters.convertTemplate(ext, src)
	}

	override Uri location() {
		componentType.qname.toUri
	}

	override const Bool 	isModified		:= false
	override const DateTime	lastModified	:= DateTime.now
}

@NoDoc
const class TemplateSourceNull : TemplateSource {
	override const Uri 		location
	override const Str 		template		:= Str.defVal
	override const Bool 	isModified		:= false
	override const DateTime	lastModified 	:= DateTime.now
	
	new make(Uri location) {
		this.location = location
	}
}
