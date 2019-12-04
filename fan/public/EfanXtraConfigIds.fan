
** [IocConfig]`pod:afIocConfig` values as provided by 'efanXtra'. 
** To change their value, override them in your 'AppModule'. Example:
** 
** pre>
** syntax: fantom
** 
** @Contribute { serviceType=ApplicationDefaults# } 
** static Void configureAppDefaults(Configuration config) {
**     config[EfanXtraConfigIds.templateTimeout] = 1min
** }
** <pre
@NoDoc @Deprecated
const mixin EfanXtraConfigIds {

	// FIXME document this and kill me
	** The time before the file system is checked for template updates.
	** 
	** Defaults to '2min' in prod, and '2sec' otherwise.
	static const Str templateTimeout	:= "afEfan.templateTimeout"

}
