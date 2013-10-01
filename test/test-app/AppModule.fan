using afIoc

internal class AppModule {
	
	static Void bind(ServiceBinder binder) {
		binder.bindImpl(AfVersion#)
	}

	@Contribute { serviceType=EfanLibraries# }
	internal static Void contributeEfanLibraries(MappedConfig config) {
		config["app"] = AppModule#.pod
	}

}
