
** To use [afSlim]`` templates add the following to your 'AppModule':
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
const class TemplateConverters {
	
	private const Str:|File->Str| converters
	
	new make(Str:|File->Str| converters) {
		this.converters = converters
	}
	
	Str convertTemplate(File templateFile) {
		if (converters.containsKey(templateFile.ext))
			return converters[templateFile.ext].call(templateFile)
		throw Err("Blegh!")	// TODO: better err msg
	}
}
