
** [IocConfig]`http://fantomfactory.org/pods/afIocConfig` values as provided by 'efanXtra'. 
** To change their value, override them in your 'AppModule'. Example:
** 
** pre>
** @Contribute { serviceType=ApplicationDefaults# } 
** static Void configureAppDefaults(MappedConfig config) {
**     config[EfanXtraConfigIds.templateTimeout] = 1min
** }
** <pre
const class EfanXtraConfigIds {

	** The time before the file system is checked for template updates.
	** 
	** Defaults to '2min' in prod, and '2sec' otherwise.
	static const Str templateTimeout	:= "afEfan.templateTimeout"

}
