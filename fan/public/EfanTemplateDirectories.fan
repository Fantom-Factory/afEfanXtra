using afEfan::EfanErr

** (Service) - Contribute directories that may contain efan / slim templates.
** 
** pre>
** using afEfanXtra::EfanTemplateDirectories
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
			if (!it.isDir) // also called when file does not exist
				throw EfanErr(ErrMsgs.templateDirIsNotDir(it))
		}
		this.templateDirs = templateDirs.toImmutable
	}
}