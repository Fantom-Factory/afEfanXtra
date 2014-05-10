using concurrent
using afIoc
using afIocConfig
using afEfan::EfanCompiler
using afPlastic::PlasticCompiler


** The [IoC]`http://www.fantomfactory.org/pods/afIoc` module class.
** 
** This class is public so it may be referenced explicitly in test code.
@NoDoc
const class EfanXtraModule {

	internal static Void bind(ServiceBinder binder) {
		// .withoutProxy to add some speed performance
		binder.bind(ComponentFinder#)		.withoutProxy
		binder.bind(ComponentCompiler#)		.withoutProxy
		binder.bind(ComponentCache#)
		binder.bind(ComponentMeta#)			.withoutProxy
		binder.bind(EfanLibraryCompiler#)	.withoutProxy
		binder.bind(EfanLibraries#)			.withoutProxy
		binder.bind(EfanXtraPrinter#)		.withoutProxy
		
		binder.bind(EfanXtra#)				.withoutProxy
		binder.bind(TemplateConverters#)	.withoutProxy
		binder.bind(TemplateDirectories#)	.withoutProxy
		binder.bind(TemplateFinders#)		.withoutProxy
		binder.bind(FandocToHtmlConverter#)	.withoutProxy
		
		// rely on afBedSheet to set srcCodePadding in PlasticCompiler (to be picked up by EfanCompiler) 
		binder.bind(EfanCompiler#)			.withoutProxy
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
		config["afEfanXtra.componentCache"] = ActorPool() { it.maxThreads = 5 }
	}

	@Contribute { serviceType=DependencyProviderSource# }
	internal static Void contributeDependencyProviderSource(OrderedConfig config) {
		config.add(config.autobuild(LibraryProvider#))
	}	

	@Contribute { serviceType=FactoryDefaults# }
	internal static Void contributeFactoryDefaults(MappedConfig config) {
		config[EfanXtraConfigIds.templateTimeout]		= 30sec
		config[EfanXtraConfigIds.supressStartupLogging]	= false
	}
	
	@Contribute { serviceType=RegistryStartup# }
	internal static Void contributeRegistryStartup(OrderedConfig conf, EfanXtraPrinter efanPrinter) {
		conf.add |->| {
			efanPrinter.logLibraries
		}
	}
}
