using concurrent
using afConcurrent
using afIoc
using afIocConfig
using afIocEnv
using afEfan::EfanEngine
using afPlastic::PlasticCompiler

** The [IoC]`pod:afIoc` module class.
** 
** This class is public so it may be referenced explicitly in test code.
@NoDoc
const class EfanXtraModule {

	static Void defineServices(RegistryBuilder defs) {
		defs.addService(ComponentFinder#)		.withRootScope
		defs.addService(ComponentCompiler#)		.withRootScope
		defs.addService(ComponentCache#)		.withRootScope
		defs.addService(ComponentMeta#)			.withRootScope
		defs.addService(ComponentCtxMgr#)		.withRootScope
		defs.addService(ComponentRenderer#)		.withRootScope
		defs.addService(EfanLibraryCompiler#)	.withRootScope
		defs.addService(EfanLibraries#)			.withRootScope
		defs.addService(EfanXtraPrinter#)		.withRootScope
		
		defs.addService(EfanXtra#)				.withRootScope
		defs.addService(TemplateConverters#)	.withRootScope
		defs.addService(TemplateDirectories#)	.withRootScope
		defs.addService(TemplateFinders#)		.withRootScope
		defs.addService(FandocToHtmlConverter#)	.withRootScope

		defs.addService(EfanEngine#)			.withRootScope
	}
	
	internal static Void onRegistryStartup(Configuration config, EfanXtraPrinter efanPrinter) {
		config.set("afEfanXtra.logLibraries", |->| {
			efanPrinter.logLibraries
		}).after("afIoc.logServices")
	}

	@Contribute { serviceType=TemplateFinders# }
	internal static Void contributeTemplateFinders(Configuration config) {
		// put renderTemplate() first, so you may temporarily override / disable templates. 
		config["afEfanXtra.findByRenderTemplateMethod"] = config.build(FindEfanByRenderTemplateMethod#)
		config["afEfanXtra.findByFacetValue"]			= config.build(FindEfanByFacetValue#)
		config["afEfanXtra.findByTypeNameOnFileSystem"] = config.build(FindEfanByTypeNameOnFileSystem#)
		config["afEfanXtra.findByTypeNameInPod"]		= config.build(FindEfanByTypeNameInPod#)
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
		config["afEfanXtra.libraryProvider"] = config.build(LibraryProvider#)
	}	

	@Contribute { serviceType=FactoryDefaults# }
	internal static Void contributeFactoryDefaults(Configuration config, IocEnv env) {
		config[EfanXtraConfigIds.templateTimeout] = env.isProd ? 2min : 2sec
	}
}
