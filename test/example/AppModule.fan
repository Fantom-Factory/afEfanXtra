using afIoc

@NoDoc
@SubModule { modules=[EfanXtraModule#]} 
class EfanAppModule {
	
	static Void defineServices(ServiceDefinitions defs) {
		defs.add(DvdService#)
	}

	// contribute all components in our pod as a library named 'app' 
	@Contribute { serviceType=EfanLibraries# }
	static Void contributeEfanLibraries(Configuration config) {
		config["app"] = EfanAppModule#.pod
	}
	
}
