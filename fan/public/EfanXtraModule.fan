using concurrent
using afIoc
using afIocConfig
using afIocEnv
using afEfan::EfanEngine
using afPlastic::PlasticCompiler

** The [IoC]`http://www.fantomfactory.org/pods/afIoc` module class.
** 
** This class is public so it may be referenced explicitly in test code.
@NoDoc
const class EfanXtraModule {

	static Void defineServices(ServiceDefinitions defs) {
		defs.add(ComponentFinder#)
		defs.add(ComponentCompiler#)
		defs.add(ComponentCache#).withProxy
		defs.add(ComponentMeta#)
		defs.add(ComponentCtxMgr#)
		defs.add(ComponentRenderer#)
		defs.add(EfanLibraryCompiler#)
		defs.add(EfanLibraries#)
		defs.add(EfanXtraPrinter#)
		
		defs.add(EfanXtra#).withProxy
		defs.add(TemplateConverters#)
		defs.add(TemplateDirectories#)
		defs.add(TemplateFinders#)
		defs.add(FandocToHtmlConverter#)

		// rely on afBedSheet to set srcCodePadding in PlasticCompiler (to be picked up by EfanCompiler) 
		defs.add(EfanEngine#)
	}
	
	@Contribute { serviceType=TemplateFinders# }
	internal static Void contributeTemplateFinders(Configuration config) {
		// put renderTemplate() first, so you may temporarily override / disable templates. 
		config["afEfanXtra.findByRenderTemplateMethod"] = config.autobuild(FindEfanByRenderTemplateMethod#)
		config["afEfanXtra.findByFacetValue"]			= config.autobuild(FindEfanByFacetValue#)
		config["afEfanXtra.findByTypeNameOnFileSystem"] = config.autobuild(FindEfanByTypeNameOnFileSystem#)
		config["afEfanXtra.findByTypeNameInPod"]		= config.autobuild(FindEfanByTypeNameInPod#)
	}	

	@Contribute { serviceType=TemplateConverters# }
	internal static Void contributeTemplateConverters(Configuration config, FandocToHtmlConverter fandocToHtml) {
		config["efan"] 	 = |File file -> Str| { file.readAllStr }
		config["fandoc"] = |File file -> Str| { fandocToHtml.convert(file) }
	}

	@Contribute { serviceType=ActorPools# }
	static Void contributeActorPools(Configuration config) {
		config["afEfanXtra.caches"] = ActorPool() { it.name = "afEfanXtra.componentCache"; it.maxThreads = 5 }
	}

	@Contribute { serviceType=DependencyProviders# }
	internal static Void contributeDependencyProviders(Configuration config) {
		config["afEfanXtra.libraryProvider"] = config.autobuild(LibraryProvider#)
	}	

	@Contribute { serviceType=FactoryDefaults# }
	internal static Void contributeFactoryDefaults(Configuration config, IocEnv env) {
		config[EfanXtraConfigIds.templateTimeout] = env.isProd ? 2min : 2sec
	}
	
	@Contribute { serviceType=RegistryStartup# }
	internal static Void contributeRegistryStartup(Configuration config, EfanXtraPrinter efanPrinter) {
		config["afEfanXtra.logLibraries"] = |->| {
			efanPrinter.logLibraries
		}
	}
}
