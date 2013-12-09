using afIoc::Build
using afIoc::Contribute
using afIoc::OrderedConfig
using afIoc::MappedConfig
using afIoc::ServiceBinder
using afIoc::ServiceScope
using afIoc::DependencyProvider
using afIoc::DependencyProviderSource
using afIoc::RegistryStartup
using afIoc::SubModule
using afPlastic::PlasticCompiler
using afIocConfig::IocConfigModule
using afIocConfig::IocConfigSource
using afIocConfig::FactoryDefaults
using afEfan::EfanCompiler


** The [afIoc]`http://repo.status302.com/doc/afIoc/#overview` module class.
** 
** This class is public so it may be referenced explicitly in tests.
const class EfanXtraModule {

	internal static Void bind(ServiceBinder binder) {
		binder.bindImpl(ComponentFinder#)
		binder.bindImpl(ComponentCompiler#)
		binder.bindImpl(ComponentCache#)
		binder.bindImpl(ComponentMeta#)
		binder.bindImpl(EfanLibraryCompiler#)
		binder.bindImpl(EfanLibraries#)
		binder.bindImpl(EfanXtraPrinter#)
		
		binder.bindImpl(EfanXtra#).withoutProxy
		binder.bindImpl(EfanTemplateConverters#)
		binder.bindImpl(EfanTemplateDirectories#)
		binder.bindImpl(EfanTemplateFinders#)
	}
	
	@Build { serviceId="EfanCompiler" }
	internal static EfanCompiler buildEfanCompiler(IocConfigSource configSrc, PlasticCompiler plasticCompiler) {
		// rely on afBedSheet to set srcCodePadding in PlasticCompiler (to be picked up by EfanCompiler) 
		EfanCompiler(plasticCompiler) {
			it.rendererClassName	= configSrc.getCoerced(EfanXtraConfigIds.rendererClassName, Str#)
		}
	}

	@Contribute { serviceType=EfanTemplateFinders# }
	internal static Void contributeEfanTemplateFinders(OrderedConfig config) {
		config.addOrdered("FindByFacetValue", 			config.autobuild(FindEfanByFacetValue#))
		config.addOrdered("FindByTypeNameOnFileSystem",	config.autobuild(FindEfanByTypeNameOnFileSystem#))
		config.addOrdered("FindByTypeNameInPod", 		config.autobuild(FindEfanByTypeNameInPod#))
	}	

	@Contribute { serviceType=EfanTemplateConverters# }
	internal static Void contributeEfanTemplateConverters(MappedConfig config) {
		config["efan"] = |File file -> Str| {
			file.readAllStr
		}
	}	
	
	@Contribute { serviceType=DependencyProviderSource# }
	internal static Void contributeDependencyProviderSource(OrderedConfig config) {
		config.add(config.autobuild(LibraryProvider#))
	}	

	@Contribute { serviceType=FactoryDefaults# }
	internal static Void contributeFactoryDefaults(MappedConfig config) {
		config[EfanXtraConfigIds.templateTimeout]		= 10sec
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
