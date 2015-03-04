using afIoc

@SubModule { modules=[EfanXtraModule#]} 
internal class TestModule {
	
	static Void bind(ServiceBinder binder) {
		binder.bindImpl(AfVersion#)
	}

	@Contribute { serviceType=EfanLibraries# }
	internal static Void contributeEfanLibraries(MappedConfig config) {
		config["app"] = AppModule#.pod
	}

}
