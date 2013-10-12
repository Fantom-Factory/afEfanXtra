using afIoc

@SubModule { modules=[EfanExtraModule#]} 
class AppModule {
	
	static Void bind(ServiceBinder binder) {
		binder.bindImpl(DvdService#)
	}

	// contribute all components in our pod as a library named 'app' 
	@Contribute { serviceType=EfanLibraries# }
	static Void contributeEfanLibraries(MappedConfig config) {
		config["app"] = AppModule#.pod
	}
	
}
