
internal class TestEfanLibraries : EfanTest {

	override Void setup() { }
	
	Void testLibNamesMustBeValid() {

		verifyEfanErrMsg("Efan Library name is not valid. It must be a legal Fantom name : Wot Ever") {
			libs := ["Wot Ever":Pod.of(this)]
			EfanLibrariesImpl.verifyLibNames(libs)
		}

		verifyEfanErrMsg("Efan Library name is not valid. It must be a legal Fantom name : 69Dude") {
			libs := ["69Dude":Pod.of(this)]
			EfanLibrariesImpl.verifyLibNames(libs)
		}
	}

}