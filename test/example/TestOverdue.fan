using afIoc
using afIocConfig
using concurrent::Actor

class TestOverdue : Test {
	
	Void testOverdue() {
		registry  := (Registry) RegistryBuilder().addModules([EfanAppModule#, IocConfigModule#]).build.startup
		
		efanExtra := (EfanExtra) registry.dependencyByType(EfanExtra#)
		overdue	  := efanExtra.render(Overdue#, ["Mr Smith"])
		
		echo("[${overdue}]")
		verifyEq(overdue, `test/example/letter.txt`.toFile.readAllStr)
		
		if (Actor.locals["efanExtra.componentCtx"] != null) {
			afIoc::IocHelper.locals.each |val, key| {
				Env.cur.err.printLine("$key = $val")
			}
			Actor.sleep(20ms)
			fail("ComponentCtx did not clean up after itself")
		}
		
		registry.shutdown
	}
}
