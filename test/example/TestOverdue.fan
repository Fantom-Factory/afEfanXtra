using afIoc

class TestOverdue : Test {
	
	Void testOverdue() {
		registry  := (Registry) RegistryBuilder().addModules([AppModule#]).build.startup
		
		efanExtra := (EfanExtra) registry.dependencyByType(EfanExtra#)
		overdue	  := efanExtra.render(Overdue#, ["Mr Smith"])
		
		echo("[${overdue}]")
		verifyEq(overdue, `test/example/letter.txt`.toFile.readAllStr)
		
		registry.shutdown
	}
}
