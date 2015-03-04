
internal class TestEfanLibraries : EfanTest {

	override Void setup() { }
	
	Void testLibNamesMustBeValid() {

		verifyEfanErrMsg(ErrMsgs.libraryNameNotValid("Wot Ever")) {
			libs := ["Wot Ever":Pod.of(this)]
			EfanLibrariesImpl.verifyLibNames(libs)
		}

		verifyEfanErrMsg(ErrMsgs.libraryNameNotValid("69Dude")) {
			libs := ["69Dude":Pod.of(this)]
			EfanLibrariesImpl.verifyLibNames(libs)
		}
	}

}