using concurrent

internal class TestAfterMethod : EfanTest {
	
	Void testAfterMethodLoop() {
		text := efanExtra.render(T_AfterLoop#)
		verifyEq(text, "Yo Yo Yo ")
	}
}
