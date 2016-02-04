using afEfan::EfanErr

** (Service - Advanced Use) - 
** Contribute functions to convert files into efan templates. 
** 
** Some templates, such as [Slim]`http://fantomfactory.org/pods/afSlim` templates, need to be 
** pre-processed / converted to efan notation before they can be compiled. To do this, a conversion 
** function is looked up via the file extension. 
** 
** By default, the following extensions are recognised:
** 
**  - '.efan'
**  - '.fandoc' (template are also converted to HTML)
**  - '.slim' (when Slim is added as a project dependency)
** 
** @uses Configuration of 'Str : |Str src->Str|' - file ext to func that converts the src to an efan template 
@NoDoc	// advanced use only
const mixin TemplateConverters {

	** Converts the given source 'Str' to an efan template Str.
	** 
	** If no matching extension is found, the given 'templateStr' is returned as is. 
	abstract Str convertTemplate(Str ext, Str templateStr)
	
	** Return a list of (lowercase) file extensions that denote which files can be converted to 
	** efan templates.
	** 
	** Note the extensions are *not* prefixed with a dot, e.g. '["efan", "slim"]' 
	abstract Str[] extensions()
	
	** Returns 'true' if the given file can be converted / has a known extension.
	abstract Bool canConvert(File file)
}

internal const class TemplateConvertersImpl : TemplateConverters {

	private const Str:|Str->Str| converters
	
	new make(Str:|Str->Str| converters) {
		// afIoc should give us a case-insensitive map
		this.converters = converters
	}
	
	override Str convertTemplate(Str ext, Str templateStr) {
		// just return the given Str by default
		converters[ext]?.call(templateStr) ?: templateStr
	}
	
	override Str[] extensions() {
		converters.keys
	}
	
	override Bool canConvert(File file) {
		converters.keys.contains(file.ext)
	}
}
