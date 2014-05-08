using afEfan::EfanErr

@NoDoc @Deprecated { msg="Use TemplateConverters instead." }
const mixin EfanTemplateConverters : TemplateConverters {
	override abstract Str convertTemplate(File templateFile)
	override abstract Str[] extensions()
	override abstract Bool canConvert(File file)	
}

** (Service) - Contribute functions that convert files to efan templates. 
** 
** Some templates, such as [afSlim]`http://repo.status302.com/doc/afSlim/#overview`, need to be 
** pre-processed / converted to efan notation before they can be compiled into components. Do this
** by contributing file converting functions to 'EfanTemplateConverters'. The functions are keyed 
** off a file extension.
**
** Example, to use [afSlim]`http://repo.status302.com/doc/afSlim/#overview` templates add the 
** following to your 'AppModule':
** 
** pre>
** using afIoc
** using afSlim
** using afEfanXtra
** 
** class AppModule {
** 
**   @Contribute { serviceType=EfanTemplateConverters# }
**   static Void contributeSlimTemplates(MappedConfig config, Slim slim) {
**     config["slim"] = |File file -> Str| { slim.parseFromFile(file) }
**   }
** }
** <pre
** 
** That will convert all files with a '.slim' extension to an efan template.
** 
** @uses Mapped config of '[Str:|File->Str|]' - file ext to func that converts the file to an efan template 
const mixin TemplateConverters {

	** Converts the given 'File' to an efan template Str.
	abstract Str convertTemplate(File templateFile)
	
	** Return a list of (lowercase) file extensions that denote which files can be converted to 
	** efan templates.
	** 
	** Note the extensions are *not* prefixed with a dot, e.g. '["efan", "slim"]' 
	abstract Str[] extensions()
	
	** Returns 'true' if the given file can be converted / has a known extension.
	abstract Bool canConvert(File file)
}

internal const class TemplateConvertersImpl : EfanTemplateConverters {

	private const Str:|File->Str| converters
	
	new make(Str:|File->Str| converters) {
		// afIoc should give us a case-insensitive map
		this.converters = converters
	}
	
	override Str convertTemplate(File templateFile) {
		if (converters.containsKey(templateFile.ext))
			return converters[templateFile.ext].call(templateFile)
		throw EfanErr(ErrMsgs.templateConverterNotFound(templateFile))
	}
	
	override Str[] extensions() {
		converters.keys
	}
	
	override Bool canConvert(File file) {
		converters.keys.contains(file.ext)
	}
}
