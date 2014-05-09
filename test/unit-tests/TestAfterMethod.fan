using concurrent

internal class TestAfterMethod : EfanTest {
	
	Void testAfterMethodLoop() {
		text := efanXtra.component(T_AfterLoop#).renderTemplate
		verifyEq(text, "Yo Yo Yo ")
	}
}
