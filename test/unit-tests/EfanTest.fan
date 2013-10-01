using afIoc

internal class EfanTest : Test {
	Registry? reg
	ComponentCache? cache
	
	override Void setup() {
		reg 	= RegistryBuilder().addModules([AppModule#, EfanExtraModule#]).build.startup
		cache	= reg.dependencyByType(ComponentCache#)
	}

	override Void teardown() {
		reg?.shutdown
	}
}
