
** Config values as used by Efan. 
** To change their value, override them in your 'AppModule'. Example:
** 
** pre>
** @Contribute { serviceType=ApplicationDefaults# } 
** static Void configureAppDefaults(MappedConfig conf) {
** 
**   conf[EfanConfigIds.templateTimeout] = 1min
** 
** }
** <pre
const mixin EfanConfigIds {

	** The time before the file system is checked for template updates.
	** Defaults to '10sec'
	static const Str templateTimeout	:= "afEfan.templateTimeout"

	** The class name given to compiled efan renderer instances.
	** Defaults to 'EfanRendererImpl'
	static const Str rendererClassName	:= "afEfan.rendererClassName"

}
