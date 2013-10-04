using afEfan::EfanErr

** Some templates, such as [afSlim]`http://repo.status302.com/doc/afSlim/#overview`, need to be 
** pre-processed / converted to efan notation before they can be compiled into components. Do this
** by contributing file converting functions to 'TemplateConverters'. The functions are keyed off
** a file extension.
** 
** Example, to use [afSlim]`http://repo.status302.com/doc/afSlim/#overview` templates add the 
** following to your 'AppModule':
** 
** pre>
** using afSlim::SlimCompiler
** using afEfanExtra::TemplateConverters
** 
** ...
** 
** @Contribute { serviceType=TemplateConverters# }
** internal static Void contributeTemplateConverters(MappedConfig config, SlimCompiler slimCompiler) {
**   config["slim"] = |File file -> Str| {
**     slimCompiler.compileFromFile(file)
**   }
** }
** <pre
** 
** @uses Mapped config of '[Str:|File->Str|]' - file ext to func that converts the file to an efan str 
const mixin TemplateConverters {
	
	abstract Str convertTemplate(File templateFile)
	
	** Return a list of (lowercase) file extensions that denote which files can be converted to 
	** efan templates.
	** 
	** Note the extensions are *not* prefixed with a dot, e.g. '["efan", "slim"]' 
	abstract Str[] extensions()
}

internal const class TemplateConvertersImpl : TemplateConverters {
	
	private const Str:|File->Str| converters
	
	new make(Str:|File->Str| converters) {
		this.converters = converters
	}
	
	override Str convertTemplate(File templateFile) {
		if (converters.containsKey(templateFile.ext))
			return converters[templateFile.ext].call(templateFile)
		throw EfanErr(ErrMsgs.templateConverterNotFound(templateFile))
	}
	
	override Str[] extensions() {
		converters.keys.map { it.lower }
	}
}
