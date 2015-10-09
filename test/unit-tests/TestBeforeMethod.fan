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
			Env.cur.err.printLine(traceErr(e, 100))
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

	static Str traceErr(Err err, Int maxDepth := 50) {
		b := Buf()	// can't trace to a StrBuf
		err.trace(b.out, ["maxDepth":maxDepth])
		return b.flip.in.readAllStr
	}
}
