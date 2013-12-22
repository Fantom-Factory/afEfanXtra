using concurrent

internal class TestInitMethod : EfanTest {
	
	Void testInitFalseAborts() {
		text := efanXtra.render(T_InitFalseAborts#)
		verifyEq(text, "")
	}

	Void testInitTrueOkay() {
		text := efanXtra.render(T_InitTrueOkay#)
		verifyEq(text, "Hello!")
	}

	Void testInitReturnsObjThrowsErr() {
		verifyEfanErrMsg(ErrMsgs.componentCompilerWrongReturnType(T_InitReturnsObj#initRender, [Void#, Bool#])) {
			text := efanXtra.render(T_InitReturnsObj#)			
		}
	}

	Void testInitParams() {
		text := efanXtra.render(T_InitParams#, ["Dude", 69])
		verifyEq(text, "X := Dude; Y := 69;")
	}

	Void testInitHandlesNulls() {
		text := efanXtra.render(T_InitParams#, [null, 69])
		verifyEq(text, "X := null; Y := 69;")
	}
}
