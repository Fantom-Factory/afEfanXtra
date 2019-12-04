using afEfan::EfanCompilationErr

internal class TestUnknownVariable : EfanTest {
	
	Void testUnknownVariableErrHasAlienAid() {
		try {
			render(UnknownVariable#)
			fail
		} catch (EfanCompilationErr err) {
			msg := (Str) err.msg
			verifyEq(msg.splitLines[-1], "  ALIEN-AID: Did you mean: app.renderSignOff(...) ???")
		}
	}
}
