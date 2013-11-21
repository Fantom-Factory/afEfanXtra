using afEfan::EfanErr

** (Service) - Contribute directories that may contain efan / slim templates.
** 
** pre>
** using afEfanExtra::EfanTemplateDirectories
** 
** ...
** 
** @Contribute { serviceType=EfanTemplateDirectories# }
** static Void contributeefanDirs(MappedConfig config) {
**   config.add(`etc/web/pages/`)
** }
** <pre
const mixin EfanTemplateDirectories {
	** the list of contributed directories
	abstract File[] templateDirs()
}

internal const class EfanTemplateDirectoriesImpl : EfanTemplateDirectories {
	
	override const File[] templateDirs
	
	new make(File[] templateDirs) {
		templateDirs.each {  
			if (!it.isDir) 
				throw EfanErr(ErrMsgs.templateDirIsNotDir(it))
			if (!it.exists) 
				throw EfanErr(ErrMsgs.templateDirNotFound(it))
		}
		this.templateDirs = templateDirs.toImmutable
	}
}