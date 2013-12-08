using concurrent

internal class TestAfterMethod : EfanTest {
	
	Void testAfterMethodLoop() {
		text := efanXtra.render(T_AfterLoop#)
		verifyEq(text, "Yo Yo Yo ")
	}
}
