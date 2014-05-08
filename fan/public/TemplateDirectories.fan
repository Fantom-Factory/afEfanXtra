using afEfan::EfanErr

@NoDoc @Deprecated { msg="Use TemplateDirectories instead." }
const mixin EfanTemplateDirectories : TemplateDirectories {
	override abstract File[] templateDirs()
}

** (Service) - Contribute directories that may contain efan / slim templates.
** 
** By contributing to 'EfanTemplateDirectories' you can force 'efanXtra' to look in file system directories when 
** searching for efan templates.
** 
** pre>
** using afIoc
** using afEfanXtra
** 
** class AppModule {
** 
**   @Contribute { serviceType=EfanTemplateDirectories# }
**   static Void contributeEfanDirs(MappedConfig config) {
**     config.add(`etc/components/`)
**   }
** }
** <pre
** 
** This has the advantage of, that during development, your pod doesn't need to be re-built and your application 
** re-started just to see template changes. 
** 
** Note that directories are **not** searched recursively, if you place templates in both 'etc/components/' and 
** 'etc/components/admin/' then you would need to add them both:
** 
**   config.add(`etc/components/`)
**   config.add(`etc/components/admin/`)
** 
** Note that directory uris need to end with a /slash/.
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