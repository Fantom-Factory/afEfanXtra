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
@SubModule { modules=[IocConfigModule#]} 
const class EfanExtraModule {

	internal static Void bind(ServiceBinder binder) {
		binder.bindImpl(LibraryCompiler#)
		binder.bindImpl(ComponentFinder#)
		binder.bindImpl(ComponentCompiler#)
		binder.bindImpl(ComponentCache#)
		binder.bindImpl(ComponentMeta#)
		binder.bindImpl(ComponentHelper#).withScope(ServiceScope.perInjection)
		binder.bindImpl(EfanLibraries#)
		binder.bindImpl(EfanExtraPrinter#)
		
		binder.bindImpl(EfanExtra#).withoutProxy
		binder.bindImpl(TemplateConverters#)
	}

	@Contribute { serviceType=TemplateConverters# }
	internal static Void contributeTemplateConverters(MappedConfig config) {
		config["efan"] = |File file -> Str| {
			file.readAllStr
		}
	}	
	
	@Contribute { serviceType=DependencyProviderSource# }
	internal static Void contributeDependencyProviderSource(OrderedConfig config) {
		config.add(config.autobuild(LibraryProvider#))
	}	
	
	@Build { serviceId="EfanCompiler" }
	internal static EfanCompiler buildEfanCompiler(IocConfigSource configSrc, PlasticCompiler plasticCompiler) {
		// rely on afBedSheet to set srcCodePadding in PlasticCompiler (to be picked up by EfanCompiler) 
		EfanCompiler(plasticCompiler) {
			it.ctxVarName 			= configSrc.getCoerced(EfanConfigIds.ctxVarName, Str#)
			it.rendererClassName	= configSrc.getCoerced(EfanConfigIds.rendererClassName, Str#)
		}
	}

	@Contribute { serviceType=FactoryDefaults# }
	internal static Void contributeFactoryDefaults(MappedConfig config) {
		config[EfanConfigIds.templateTimeout]	= 10sec
		config[EfanConfigIds.ctxVarName]		= "ctx"
		config[EfanConfigIds.rendererClassName]	= "EfanRendererImpl"
	}
	
	@Contribute { serviceType=RegistryStartup# }
	internal static Void contributeRegistryStartup(OrderedConfig conf, EfanExtraPrinter efanPrinter) {
		conf.add |->| {
			efanPrinter.libraryDetailsToStr
		}
	}
	
}
