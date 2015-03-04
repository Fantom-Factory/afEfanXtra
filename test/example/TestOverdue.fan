using afIoc
using afIocConfig
using afIocEnv
using concurrent::Actor

class TestOverdue : Test {
	
	Void testOverdue() {
		registry  := (Registry) RegistryBuilder().addModules([EfanAppModule#, ConfigModule#, IocEnvModule#]).build.startup
		
		efanXtra := (EfanXtra) registry.dependencyByType(EfanXtra#)
		overdue	 := efanXtra.component(Overdue#).render(["Mr Smith"])
		
		echo("[${overdue}]")
		verifyEq(overdue, `test/example/letter.txt`.toFile.readAllStr)
		
		if (Actor.locals["efanXtra.componentCtx"] != null) {
//			afIoc::IocHelper.locals.each |val, key| {
//				Env.cur.err.printLine("$key = $val")
//			}
//			Actor.sleep(20ms)
			fail("ComponentCtx did not clean up after itself")
		}
		
		registry.shutdown
	}
}
