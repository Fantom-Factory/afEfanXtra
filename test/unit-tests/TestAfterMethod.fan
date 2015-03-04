using concurrent

internal class TestAfterMethod : EfanTest {
	
	Void testAfterMethodLoop() {
		text := efanXtra.component(T_AfterLoop#).render
		verifyEq(text, "Yo Yo Yo ")
	}
}
