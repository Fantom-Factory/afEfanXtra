using afIoc
using afIocConfig
using afIocEnv
using concurrent::Actor
using afConcurrent::ConcurrentModule
using afPlastic::PlasticModule
using afEfan::EfanModule

class TestOverdue : Test {
	
	Void testOverdue() {
		registry := RegistryBuilder().addModulesFromPod("afEfanXtra").addModule(EfanAppModule#).build
		efanXtra := (EfanXtra) registry.rootScope.serviceByType(EfanXtra#)
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
