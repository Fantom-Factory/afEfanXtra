using concurrent
using afIoc
using afIocConfig

@NoDoc
const mixin TemplateSource {
	
	** Should update any modified timestamps
	abstract Str template()
	
	** Uri for debug purposes
	abstract Uri location()
	
	** Should not update any internal state
	abstract Bool isModified()

	abstract DateTime lastModified()	// for sitemap
	
	** leaky abstraction - called when last checked should be updated
	abstract Void checked()
}

@NoDoc
const class TemplateSourceFile : TemplateSource {
	@Inject	private const TemplateConverters templateConverters

	@Inject	
	@Config { id="afEfan.templateTimeout" }
	private const Duration? timeout
	private const File 		templateFile
	private const AtomicRef	lastCheckedRef	:= AtomicRef()
	private const AtomicRef	lastModifiedRef	:= AtomicRef()	

	** pod files have last modified info too!
	new make(File file, |This| in) {
		in(this)
		this.templateFile			= file
		this.lastCheckedRef.val		= DateTime.now
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
		isTimedOut && isModifyed 
	}

	override Void checked() {
		this.lastCheckedRef.val	= DateTime.now		
	}

	override DateTime lastModified() {
		lastModifiedRef.val
	}
	private	DateTime lastChecked() {
		lastCheckedRef.val
	}
	
	private Bool isTimedOut() {
		timeout == null
			? true
			: (DateTime.now - lastChecked) > timeout
	}
	
	private Bool isModifyed() {
		templateFile.modified > lastModified
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
	override 	   Void 	checked()		{ }
}

@NoDoc
const class TemplateSourceNull : TemplateSource {
	override const Uri 		location
	override const Str 		template		:= Str.defVal
	override const Bool 	isModified		:= false
	override const DateTime	lastModified 	:= DateTime.now
	override 	   Void		checked()		{ }
	
	new make(Uri location) {
		this.location = location
	}
}
