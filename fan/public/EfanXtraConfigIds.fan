
** [IocConfig]`http://fantomfactory.org/pods/afIocConfig` values as provided by 'efanXtra'. 
** To change their value, override them in your 'AppModule'. Example:
** 
** pre>
** @Contribute { serviceType=ApplicationDefaults# } 
** static Void configureAppDefaults(MappedConfig config) {
**     config[EfanXtraConfigIds.templateTimeout] = 1min
** }
** <pre
const mixin EfanXtraConfigIds {

	** The time before the file system is checked for template updates.
	** Defaults to '5sec'
	static const Str templateTimeout	:= "afEfan.templateTimeout"

	** If 'true' then the useful component info at startup will not be logged.
	** Defaults to 'false'
	static const Str supressStartupLogging	:= "afEfan.supressStartupLogging"

}
