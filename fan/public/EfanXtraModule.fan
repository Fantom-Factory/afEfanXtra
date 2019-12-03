using concurrent::ActorPool
using afConcurrent::ActorPools
using afIoc
using afIocConfig::FactoryDefaults
using afIocEnv::IocEnv
using afPlastic::PlasticCompiler
using afEfan::EfanCompiler

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
		defs.addService(ObjCache#)				.withRootScope

		// FIXME kill me - defs.addModule(afEfan::EfanModule#)
		defs.addModule(afEfan::EfanModule#)
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
		config["afEfanXtra.findByTypeFandoc"]			= config.build(FindEfanByTypeFandoc#)
		config["afEfanXtra.findByTypeNameOnFileSystem"] = config.build(FindEfanByTypeNameOnFileSystem#)
		config["afEfanXtra.findByTypeNameInPod"]		= config.build(FindEfanByTypeNameInPod#)
	}	

	@Contribute { serviceType=TemplateConverters# }
	internal static Void contributeTemplateConverters(Configuration config, FandocToHtmlConverter fandocToHtml) {
		config["efan"] 	 = |Str src -> Str| { src }
		config["fandoc"] = |Str src -> Str| { fandocToHtml.convert(src) }
	}

	@Contribute { serviceType=ActorPools# }
	static Void contributeActorPools(Configuration config) {
		config["afEfanXtra.caches"] = ActorPool() { it.name = "afEfanXtra.componentCache"; it.maxThreads = 5 }
	}

	@Contribute { serviceType=DependencyProviders# }
	internal static Void contributeDependencyProviders(Configuration config) {
		config["afEfanXtra.libraryProvider"] = config.build(LibraryProvider#)
	}	

	@Contribute { serviceType=EfanCompiler# }
	Void contributeEfanCompilerCallbacks(Configuration config) {
		instance := (CompilerCallback) config.build(CompilerCallback#)
		config.add(CompilerCallback#callback.func.bind([instance]))
	}

	@Contribute { serviceType=FactoryDefaults# }
	internal static Void contributeFactoryDefaults(Configuration config, IocEnv env) {
		config[EfanXtraConfigIds.templateTimeout] = env.isProd ? 2min : 2sec
	}
}
