using afIoc

@NoDoc
@SubModule { modules=[EfanXtraModule#]} 
const class EfanAppModule {
	
	static Void defineServices(RegistryBuilder defs) {
		defs.addService(DvdService#)
	}

	// contribute all components in our pod as a library named 'app' 
	@Contribute { serviceType=EfanLibraries# }
	static Void contributeEfanLibraries(Configuration config) {
		config["app"] = EfanAppModule#.pod
	}
	
}
