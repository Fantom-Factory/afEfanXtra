using concurrent

internal class TestBeforeMethod : EfanTest {
	
	Void testBeforeFalseAborts() {
		text := efanExtra.render(T_BeforeFalseAborts#)
		verifyEq(text, "")
	}

	Void testBeforeTrueOkay() {
		text := efanExtra.render(T_BeforeTrueOkay#)
		verifyEq(text, "Hello!")
	}

}
