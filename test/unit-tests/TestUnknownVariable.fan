using afEfan::EfanCompilationErr

internal class TestUnknownVariable : EfanTest {
	
	Void testUnknownVariableErrHasAlienAid() {
		try {
			efanExtra.render(UnknownVariable#)
			fail
		} catch (EfanCompilationErr err) {
			msg := (Str) err.msg
			verifyEq(msg.splitLines[-1], ErrMsgs.alienAidComponentTypo("app", "SignOff").splitLines[-1])
		}
	}
}
