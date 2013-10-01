using afIoc::Build
using afIoc::Contribute
using afIoc::OrderedConfig
using afIoc::MappedConfig
using afIoc::ServiceBinder
using afIoc::ServiceScope
using afIoc::DependencyProvider
using afIoc::DependencyProviderSource
using afEfan::EfanCompiler

class EfanExtraModule {

	static Void bind(ServiceBinder binder) {
		
		binder.bindImpl(ComponentCache#)

		binder.bindImpl(ComponentCompiler#)
		binder.bindImpl(ComponentsProvider#)
		binder.bindImpl(ComponentHelper#).withScope(ServiceScope.perInjection)

		binder.bindImpl(EfanLibraries#)
		binder.bindImpl(TemplateConverters#)
	}

	@Contribute { serviceType=DependencyProviderSource# }
	internal static Void contributeDependencyProviderSource(OrderedConfig config, ComponentsProvider componentsProvider) {
		config.add(componentsProvider)
	}	
	
	@Contribute { serviceType=TemplateConverters# }
	internal static Void contributeTemplateConverters(MappedConfig config) {
		config["efan"] = |File file -> Str| {
			file.readAllStr
		}
	}	
	
//	@Contribute { serviceType=EfanLibraries# }
//	internal static Void contributeEfanLibraries(MappedConfig config) {
//		// TODO: grab from some BedSheetMeta service or somefin
//		config["app"] = AppModule#.pod
//	}
}
