using afIoc

@NoDoc
@SubModule { modules=[EfanXtraModule#]} 
class EfanAppModule {
	
	static Void bind(ServiceBinder binder) {
		binder.bind(DvdService#)
	}

	// contribute all components in our pod as a library named 'app' 
	@Contribute { serviceType=EfanLibraries# }
	static Void contributeEfanLibraries(MappedConfig config) {
		config["app"] = EfanAppModule#.pod
	}
	
}
