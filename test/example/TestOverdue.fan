using afIoc
using concurrent::Actor

class TestOverdue : Test {
	
	Void testOverdue() {
		registry  := (Registry) RegistryBuilder().addModules([AppModule#]).build.startup
		
		efanExtra := (EfanExtra) registry.dependencyByType(EfanExtra#)
		overdue	  := efanExtra.render(Overdue#, ["Mr Smith"])
		
		echo("[${overdue}]")
		verifyEq(overdue, `test/example/letter.txt`.toFile.readAllStr)
		
		
		tsm := (ThreadStashManager) registry.dependencyByType(ThreadStashManager#)
//		tsm.cleanUpThread
		

		if (Actor.locals[ComponentCtx.localsKey] != null) {
			afIoc::IocHelper.locals.each |val, key| {
				Env.cur.err.printLine("$key = $val")
			}
			Actor.sleep(20ms)
			fail("ComponentCtx did not clean up after itself")
		}
		
		registry.shutdown
	}
}
