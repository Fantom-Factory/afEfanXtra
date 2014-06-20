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

	internal static Void bind(ServiceBinder binder) {
		binder.bind(ComponentFinder#)
		binder.bind(ComponentCompiler#)
		binder.bind(ComponentCache#)		// (needs proxy)
		binder.bind(ComponentMeta#)
		binder.bind(ComponentCtxMgr#)
		binder.bind(ComponentRenderer#)
		binder.bind(EfanLibraryCompiler#)
		binder.bind(EfanLibraries#)
		binder.bind(EfanXtraPrinter#)
		
		binder.bind(EfanXtra#)
		binder.bind(TemplateConverters#)
		binder.bind(TemplateDirectories#)
		binder.bind(TemplateFinders#)
		binder.bind(FandocToHtmlConverter#)

		// rely on afBedSheet to set srcCodePadding in PlasticCompiler (to be picked up by EfanCompiler) 
		binder.bind(EfanEngine#)
	}
	
	@Contribute { serviceType=TemplateFinders# }
	internal static Void contributeTemplateFinders(OrderedConfig config) {
		// put renderTemplate() first, so you may temporarily override / disable templates. 
		config.addOrdered("FindByRenderTemplateMethod", config.autobuild(FindEfanByRenderTemplateMethod#))
		config.addOrdered("FindByFacetValue", 			config.autobuild(FindEfanByFacetValue#))
		config.addOrdered("FindByTypeNameOnFileSystem",	config.autobuild(FindEfanByTypeNameOnFileSystem#))
		config.addOrdered("FindByTypeNameInPod", 		config.autobuild(FindEfanByTypeNameInPod#))
	}	

	@Contribute { serviceType=TemplateConverters# }
	internal static Void contributeTemplateConverters(MappedConfig config, FandocToHtmlConverter fandocToHtml) {
		config["efan"] 	 = |File file -> Str| { file.readAllStr }
		config["fandoc"] = |File file -> Str| { fandocToHtml.convert(file) }
	}

	@Contribute { serviceType=ActorPools# }
	static Void contributeActorPools(MappedConfig config) {
		config["afEfanXtra.componentCache"] = ActorPool() { it.name = "afEfanXtra.componentCache"; it.maxThreads = 5 }
	}

	@Contribute { serviceType=DependencyProviders# }
	internal static Void contributeDependencyProviders(OrderedConfig config) {
		config.add(config.autobuild(LibraryProvider#))
	}	

	@Contribute { serviceType=FactoryDefaults# }
	internal static Void contributeFactoryDefaults(MappedConfig config, IocEnv env) {
		config[EfanXtraConfigIds.templateTimeout] = env.isProd ? 2min : 2sec
	}
	
	@Contribute { serviceType=RegistryStartup# }
	internal static Void contributeRegistryStartup(OrderedConfig conf, EfanXtraPrinter efanPrinter) {
		conf.addOrdered("afEfanXtra.logLibraries") |->| {
			efanPrinter.logLibraries
		}
	}
}
