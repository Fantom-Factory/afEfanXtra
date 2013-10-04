using afIoc::Build
using afIoc::Contribute
using afIoc::OrderedConfig
using afIoc::MappedConfig
using afIoc::ServiceBinder
using afIoc::ServiceScope
using afIoc::DependencyProvider
using afIoc::DependencyProviderSource
using afEfan::EfanCompiler


const class EfanExtraModule {

	static Void bind(ServiceBinder binder) {
		
		binder.bindImpl(LibraryCompiler#)
		binder.bindImpl(ComponentFinder#)
		binder.bindImpl(ComponentCompiler#)
		binder.bindImpl(ComponentCache#)
		binder.bindImpl(ComponentsProvider#)
		binder.bindImpl(ComponentHelper#).withScope(ServiceScope.perInjection)
		binder.bindImpl(EfanExtraConfig#)
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
	
}
