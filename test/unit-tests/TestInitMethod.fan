using concurrent

internal class TestInitMethod : EfanTest {
	
	Void testInitFalseAborts() {
		text := efanXtra.render(T_InitFalseAborts#)
		// technically this is correct, but I'm wondering if I should return an empty Str instead???
		verifyEq(text, false)
	}

	Void testInitTrueOkay() {
		text := efanXtra.render(T_InitTrueOkay#)
		verifyEq(text, "Hello!")
	}

	Void testInitReturnsObj() {
		text := efanXtra.render(T_InitReturnsObj#)
		verifyEq(text, 69)
	}
}
