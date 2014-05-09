using concurrent
using afEfan

internal class TestBeforeMethod : EfanTest {
	
	Void testBeforeFalseAborts() {
		text := render(T_BeforeFalseAborts#)
		verifyEq(text, "")
	}

	Void testBeforeTrueOkay() {
		try {
		text := render(T_BeforeTrueOkay#)
		verifyEq(text, "Hello!")
			
		} catch(Err e) {
						q:=Utils.traceErr(e, 100)
			Env.cur.err.printLine(q)

		}
	}

	Void testBeforeNonBool() {
		verifyErrTypeMsg(EfanErr#, ErrMsgs.componentCompilerWrongReturnType(T_BeforeNonBool#beforeRender, [Void#, Bool#])) {
			render(T_BeforeNonBool#)
		}
	}

	Void testAfterNonBool() {
		verifyErrTypeMsg(EfanErr#, ErrMsgs.componentCompilerWrongReturnType(T_AfterNonBool#afterRender, [Void#, Bool#])) {
			render(T_AfterNonBool#)
		}
	}

}
