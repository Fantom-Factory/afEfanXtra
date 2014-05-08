using concurrent
using afIoc
using afIocConfig

const mixin TemplateSource {
	
	abstract Str template()
	
	abstract Uri loc()
	
	abstract Bool isModified()
}

const class TemplateSourceFile : TemplateSource {
	@Inject	private const TemplateConverters templateConverters

	@Inject	
	@Config { id="afEfan.templateTimeout" }
	private const Duration? timeout
	private const File 		templateFile
	private const AtomicRef	lastChecked		:= AtomicRef()
	private const AtomicRef	lastModified	:= AtomicRef()	

	** pod files have last modified info too!
	new make(File file, |This| in) {
		in(this)
		this.templateFile = file
		updateTimestamp
	}
	
	override Str template() {
		template := templateConverters.convertTemplate(templateFile)
		updateTimestamp
		return template
	}

	override Uri loc() {
		templateFile.normalize.uri
	}

	override Bool isModified() {
		if (timeout == null)
			return true
		if ((DateTime.now - ((DateTime) lastChecked.val)) < timeout)
			return false
		return templateFile.modified > ((DateTime) lastModified.val)
	}

	private Void updateTimestamp() {
		lastChecked.val  = DateTime.now
		lastModified.val = templateFile.modified
	}
}

