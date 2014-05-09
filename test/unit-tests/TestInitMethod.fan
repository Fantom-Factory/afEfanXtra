using concurrent

internal class TestInitMethod : EfanTest {
	
	Void testInitFalseAborts() {
		text := render(T_InitFalseAborts#)
		verifyEq(text, "")
	}

	Void testInitTrueOkay() {
		text := render(T_InitTrueOkay#)
		verifyEq(text, "Hello!")
	}

	Void testInitReturnsObjThrowsErr() {
		verifyEfanErrMsg(ErrMsgs.componentCompilerWrongReturnType(T_InitReturnsObj#initRender, [Void#, Bool#])) {
			text := render(T_InitReturnsObj#)			
		}
	}

	Void testInitParams() {
		text := render(T_InitParams#, ["Dude", 69])
		verifyEq(text, "X := Dude; Y := 69;")
	}

	Void testInitHandlesNulls() {
		text := render(T_InitParams#, [null, 69])
		verifyEq(text, "X := null; Y := 69;")
	}
}
