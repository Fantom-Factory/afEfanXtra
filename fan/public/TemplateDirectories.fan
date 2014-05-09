using afEfan::EfanErr

@NoDoc @Deprecated { msg="Use TemplateDirectories instead." }
const mixin EfanTemplateDirectories : TemplateDirectories {
	override abstract File[] templateDirs()
}

** (Service) - Contribute directories that may contain efan / slim templates.
** 
** By contributing to 'TemplateDirectories' you can force 'efanXtra' to look in specified directories when 
** searching for efan templates.
** 
** pre>
** using afIoc
** using afEfanXtra
** 
** class AppModule {
** 
**   @Contribute { serviceType=TemplateDirectories# }
**   static Void contributeTemplateDirs(MappedConfig config) {
**     config.add(`etc/components/`)
**   }
** }
** <pre
** 
** Templates could, of course, just be placed in resource directories inside your pod.
** 
** But hosting templates in directories external to the pod has the advantage of that during 
** development, the pod does not need to be re-built and your application re-started just to see 
** template changes. 
** 
** Note that directories are **not** searched recursively, if you place templates in both 'etc/components/' and 
** 'etc/components/admin/' then you would need to add them both:
** 
**   config.add(`etc/components/`)
**   config.add(`etc/components/admin/`)
** 
** Also, directory uris need to end with a /slash/.
const mixin TemplateDirectories {
	
	** The list of contributed directories.
	abstract File[] templateDirs()
}

internal const class TemplateDirectoriesImpl : EfanTemplateDirectories {
	
	override const File[] templateDirs
	
	new make(File[] templateDirs) {
		templateDirs.each {  
			if (!it.isDir) // also called when file does not exist
				throw EfanErr(ErrMsgs.templateDirIsNotDir(it))
		}
		this.templateDirs = templateDirs.toImmutable
	}
}