using concurrent
using afIoc
using afIocConfig
using afEfan::EfanCompiler
using afPlastic::PlasticCompiler


** The [afIoc]`http://repo.status302.com/doc/afIoc/#overview` module class.
** 
** This class is public so it may be referenced explicitly in tests.
@NoDoc
const class EfanXtraModule {

	internal static Void bind(ServiceBinder binder) {
		binder.bind(ComponentFinder#)
		binder.bind(ComponentCompiler#)
		binder.bind(ComponentCache#)
		binder.bind(ComponentMeta#)
		binder.bind(EfanLibraryCompiler#)
		binder.bind(EfanLibraries#)
		binder.bind(EfanXtraPrinter#)
		
		binder.bind(EfanXtra#).withoutProxy
		binder.bind(EfanTemplateConverters#)
		binder.bind(EfanTemplateDirectories#)
		binder.bind(EfanTemplateFinders#)
		binder.bind(FandocToHtmlConverter#)
	}
	
	@Build { serviceId="EfanCompiler" }
	internal static EfanCompiler buildEfanCompiler(IocConfigSource configSrc, PlasticCompiler plasticCompiler) {
		// rely on afBedSheet to set srcCodePadding in PlasticCompiler (to be picked up by EfanCompiler) 
		EfanCompiler(plasticCompiler) {
			it.rendererClassName	= configSrc.get(EfanXtraConfigIds.rendererClassName, Str#)
		}
	}

	@Contribute { serviceType=EfanTemplateFinders# }
	internal static Void contributeEfanTemplateFinders(OrderedConfig config) {
		config.addOrdered("FindByFacetValue", 			config.autobuild(FindEfanByFacetValue#))
		config.addOrdered("FindByTypeNameOnFileSystem",	config.autobuild(FindEfanByTypeNameOnFileSystem#))
		config.addOrdered("FindByTypeNameInPod", 		config.autobuild(FindEfanByTypeNameInPod#))
	}	

	@Contribute { serviceType=EfanTemplateConverters# }
	internal static Void contributeEfanTemplateConverters(MappedConfig config, FandocToHtmlConverter fandocToHtml) {
		config["efan"] 	 = |File file -> Str| { file.readAllStr }
		config["fandoc"] = |File file -> Str| { fandocToHtml.convert(file) }
	}	

	@Contribute { serviceType=ActorPools# }
	static Void contributeActorPools(MappedConfig config) {
		config["afEfanXtra.fileCache"] = ActorPool()
	}

	@Contribute { serviceType=DependencyProviderSource# }
	internal static Void contributeDependencyProviderSource(OrderedConfig config) {
		config.add(config.autobuild(LibraryProvider#))
	}	

	@Contribute { serviceType=FactoryDefaults# }
	internal static Void contributeFactoryDefaults(MappedConfig config) {
		config[EfanXtraConfigIds.templateTimeout]		= 30sec
		config[EfanXtraConfigIds.rendererClassName]		= "EfanComponentImpl"
		config[EfanXtraConfigIds.supressStartupLogging]	= false
	}
	
	@Contribute { serviceType=RegistryStartup# }
	internal static Void contributeRegistryStartup(OrderedConfig conf, EfanXtraPrinter efanPrinter) {
		conf.add |->| {
			efanPrinter.logLibraries
		}
	}
}
