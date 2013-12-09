
** Config values as used by EfanXtra. 
** To change their value, override them in your 'AppModule'. Example:
** 
** pre>
** using afIocConfig
** 
** class AppModule {
**   ...
** 
**   @Contribute { serviceType=ApplicationDefaults# } 
**   static Void configureAppDefaults(MappedConfig conf) {
** 
**     conf[EfanXtraConfigIds.templateTimeout] = 1min
**   }
** <pre
const mixin EfanXtraConfigIds {

	** The time before the file system is checked for template updates.
	** Defaults to '10sec'
	static const Str templateTimeout	:= "afEfan.templateTimeout"

	** The class name given to compiled efan renderer instances.
	** Defaults to 'EfanRendererImpl'
	static const Str rendererClassName	:= "afEfan.rendererClassName"

	** If 'true' then the useful component info at startup will not be logged.
	** Defaults to 'false'
	static const Str supressStartupLogging	:= "afEfan.supressStartupLogging"

}
