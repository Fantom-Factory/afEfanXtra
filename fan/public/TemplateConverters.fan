using afEfan::EfanErr

@NoDoc @Deprecated { msg="Use TemplateConverters instead." }
const mixin EfanTemplateConverters : TemplateConverters {
	override abstract Str convertTemplate(File templateFile)
	override abstract Str[] extensions()
	override abstract Bool canConvert(File file)	
}

** (Service) - Contribute functions to convert files into efan templates. 
** 
** Some templates, such as [Slim]`http://fantomfactory.org/pods/afSlim` templates, need to be 
** pre-processed / converted to efan notation before they can be compiled. To do this, a conversion 
** function is looked up via the file extension. If no function is found, the file is assumed to be
** an efan template and read in as a simple string.
** 
** For example, to use [Slim]`http://fantomfactory.org/pods/afSlim` templates add the following to 
** your 'AppModule':
** 
** pre>
** using afIoc
** using afSlim
** using afEfanXtra
** 
** class AppModule {
** 
**   @Contribute { serviceType=TemplateConverters# }
**   static Void contributeSlimTemplates(MappedConfig config, Slim slim) {
**     config["slim"] = |File file -> Str| { slim.parseFromFile(file) }
**   }
** }
** <pre
** 
** This will convert all files with a '.slim' extension to an efan template.
** 
** By default, a function is supplied that converts all files with a '.fandoc' extension into HTML.
** 
** @uses Mapped config of 'Str : |File->Str|' - file ext to func that converts the file to an efan template 
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
		// just read the file by default
		converters[templateFile.ext]?.call(templateFile) ?: templateFile.readAllStr
	}
	
	override Str[] extensions() {
		converters.keys
	}
	
	override Bool canConvert(File file) {
		converters.keys.contains(file.ext)
	}
}
