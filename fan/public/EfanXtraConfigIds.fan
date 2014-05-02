
** [IocConfig]`http://repo.status302.com/doc/afIocConfig/` values as provided by 'efanXtra'. 
** To change their value, override them in your 'AppModule'. Example:
** 
** pre>
** using afIoc
** using afIocConfig
** using afEfanXtra
**  
** class AppModule {
** 
**   @Contribute { serviceType=ApplicationDefaults# } 
**   static Void configureAppDefaults(MappedConfig config) {
**     config[EfanXtraConfigIds.templateTimeout] = 1min
**   }
** }
** <pre
const mixin EfanXtraConfigIds {

	** The time before the file system is checked for template updates.
	** Defaults to '30sec'
	static const Str templateTimeout	:= "afEfan.templateTimeout"

	** The class name given to compiled efan renderer instances.
	** Defaults to 'EfanRendererImpl'
	static const Str rendererClassName	:= "afEfan.rendererClassName"

	** If 'true' then the useful component info at startup will not be logged.
	** Defaults to 'false'
	static const Str supressStartupLogging	:= "afEfan.supressStartupLogging"

}
