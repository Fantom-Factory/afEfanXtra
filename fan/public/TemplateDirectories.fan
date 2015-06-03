using afEfan::EfanErr

** (Service) - Contribute directories that may contain efan / slim templates.
** 
** By contributing to 'TemplateDirectories' you can force 'efanXtra' to look in specified directories when 
** searching for efan templates.
** 
** pre>
** syntax: fantom
** 
** using afIoc
** using afEfanXtra
** 
** class AppModule {
** 
**     @Contribute { serviceType=TemplateDirectories# }
**     static Void contributeTemplateDirs(Configuration config) {
**         config.add(`etc/components/`)
**     }
** }
** <pre
** 
** Hosting templates on the file system has the advantage that, during development, 
** the pod does not need to be re-built and your application re-started just to see 
** template changes. 
** 
** Note that directories are **not** searched recursively, if you place templates in both 'etc/components/' and 
** 'etc/components/admin/' then you would need to add them both:
** 
**   syntax: fantom
** 
**   config.add(`etc/components/`)
**   config.add(`etc/components/admin/`)
** 
** Also, directory URIs need to end with a /slash/.
const mixin TemplateDirectories {
	
	** The list of contributed directories.
	abstract File[] templateDirs()
}

internal const class TemplateDirectoriesImpl : TemplateDirectories {
	
	override const File[] templateDirs
	
	new make(File[] templateDirs) {
		templateDirs.each {  
			if (!it.isDir) // also called when file does not exist
				throw EfanErr(ErrMsgs.templateDirIsNotDir(it))
		}
		this.templateDirs = templateDirs.toImmutable
	}
}