using concurrent

internal class TestInitMethod : EfanTest {
	
	Void testInitFalseAborts() {
		text := efanExtra.render(T_InitFalseAborts#)
		verifyEq(text, "")
	}

	Void testInitTrueOkay() {
		text := efanExtra.render(T_InitTrueOkay#)
		verifyEq(text, "Hello!")
	}

}
