using concurrent::ActorPool
using afConcurrent::ActorPools
using afIoc
using afIocConfig::FactoryDefaults
using afIocEnv::IocEnv
using afPlastic::PlasticCompiler
using afEfan::EfanCompiler

using afPlastic

** The [IoC]`pod:afIoc` module class.
** 
** This class is public so it may be referenced explicitly in test code.
@NoDoc
const class EfanXtraModule {

	Void defineServices(RegistryBuilder defs) {
		defs.addService(ComponentFinder#)		.withRootScope
		defs.addService(ComponentCompiler#)		.withRootScope
		defs.addService(ComponentCache#)		.withRootScope
		defs.addService(ComponentMeta#)			.withRootScope
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
	}
	
	internal Void onRegistryStartup(Configuration config, EfanXtraPrinter efanPrinter) {
		config.set("afEfanXtra.logLibraries", |->| {
			efanPrinter.logLibraries
		}).after("afIoc.logServices")
	}

	@Override { serviceId="afEfan::EfanCompiler" }
	EfanCompiler buildCompiler(|Type, PlasticClassModel|[] compilerCallbacks, Scope scope) {
		// the default name of 'ctx' can sometimes (e.g. Eggbox) clash with component field names
		// as 'ctx' isn't used in efanXtra, just name it to something else 
		scope.build(EfanCompiler#, [compilerCallbacks], [EfanCompiler#ctxName : "_ctx_"])
	}

	@Contribute { serviceType=TemplateFinders# }
	internal Void contributeTemplateFinders(Configuration config) {
		// put renderTemplate() first, so you may temporarily override / disable templates. 
		config["afEfanXtra.findByRenderTemplateMethod"] = config.build(FindEfanByRenderTemplateMethod#)
		config["afEfanXtra.findByFacetValue"]			= config.build(FindEfanByFacetValue#)
		config["afEfanXtra.findByTypeFandoc"]			= config.build(FindEfanByTypeFandoc#)
		config["afEfanXtra.findByTypeNameOnFileSystem"] = config.build(FindEfanByTypeNameOnFileSystem#)
		config["afEfanXtra.findByTypeNameInPod"]		= config.build(FindEfanByTypeNameInPod#)
	}	

	@Contribute { serviceType=TemplateConverters# }
	internal Void contributeTemplateConverters(Configuration config, FandocToHtmlConverter fandocToHtml) {
		config["efan"] 	 = |Str src -> Str| { src }
		config["fandoc"] = |Str src -> Str| { fandocToHtml.convert(src) }
	}

	@Contribute { serviceType=ActorPools# }
	Void contributeActorPools(Configuration config) {
		config["afEfanXtra.caches"] = ActorPool() { it.name = "afEfanXtra.componentCache"; it.maxThreads = 5 }
	}

	@Contribute { serviceType=DependencyProviders# }
	internal Void contributeDependencyProviders(Configuration config) {
		config["afEfanXtra.libraryProvider"] = config.build(LibraryProvider#)
	}	

	@Contribute { serviceId="afEfan::EfanCompiler" }
	Void contributeEfanCompilerCallbacks(Configuration config) {
		instance := (CompilerCallback) config.build(CompilerCallback#)
		config.add(CompilerCallback#callback.func.bind([instance]))
	}

	@Contribute { serviceType=FactoryDefaults# }
	internal Void contributeFactoryDefaults(Configuration config, IocEnv env) {
		config["afEfanXtra.templateTimeout"] = env.isProd ? 2min : 2sec
	}
}
