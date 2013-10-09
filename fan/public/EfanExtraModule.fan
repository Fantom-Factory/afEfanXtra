using afIoc::Build
using afIoc::Contribute
using afIoc::OrderedConfig
using afIoc::MappedConfig
using afIoc::ServiceBinder
using afIoc::ServiceScope
using afIoc::DependencyProvider
using afIoc::DependencyProviderSource
using afPlastic::PlasticCompiler
using afIocConfig::IocConfigSource
using afIocConfig::FactoryDefaults
using afEfan::EfanCompiler


** The [afIoc]`http://repo.status302.com/doc/afIoc/#overview` module class.
** 
** This class is public so it may be referenced explicitly in tests.
const class EfanExtraModule {

	@NoDoc
	static Void bind(ServiceBinder binder) {
		
		binder.bindImpl(LibraryCompiler#)
		binder.bindImpl(ComponentFinder#)
		binder.bindImpl(ComponentCompiler#)
		binder.bindImpl(ComponentCache#)
		binder.bindImpl(ComponentsProvider#)
		binder.bindImpl(ComponentHelper#).withScope(ServiceScope.perInjection)
		binder.bindImpl(EfanLibraries#)
		
		binder.bindImpl(EfanExtra#)
		binder.bindImpl(TemplateConverters#)
	}

	@NoDoc
	@Contribute { serviceType=TemplateConverters# }
	internal static Void contributeTemplateConverters(MappedConfig config) {
		config["efan"] = |File file -> Str| {
			file.readAllStr
		}
	}	
	
	@NoDoc
	@Contribute { serviceType=DependencyProviderSource# }
	internal static Void contributeDependencyProviderSource(OrderedConfig config, ComponentsProvider componentsProvider) {
		config.add(componentsProvider)
	}	
	
	@NoDoc
	@Build { serviceId="EfanCompiler" }
	static EfanCompiler buildEfanCompiler(IocConfigSource configSrc, PlasticCompiler plasticCompiler) {
		// rely on afBedSheet to set srcCodePadding in PlasticCompiler (to be picked up by EfanCompiler) 
		EfanCompiler(plasticCompiler) {
			it.ctxVarName 			= configSrc.getCoerced(EfanConfigIds.ctxVarName, Str#)
			it.rendererClassName	= configSrc.getCoerced(EfanConfigIds.rendererClassName, Str#)
		}
	}

	@NoDoc
	@Contribute { serviceType=FactoryDefaults# }
	static Void contributeFactoryDefaults(MappedConfig config) {
		config[EfanConfigIds.templateTimeout]	= 10sec
		config[EfanConfigIds.ctxVarName]		= "ctx"
		config[EfanConfigIds.rendererClassName]	= "EfanRendererImpl"
	}
}
