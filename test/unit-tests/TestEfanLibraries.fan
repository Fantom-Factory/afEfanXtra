
internal class TestEfanLibraries : EfanTest {

  Void testLibNamesMustBeValid() {

    verifyEfanErrMsg(ErrMsgs.libraryNameNotValid("Wot Ever")) {
      libs := ["Wot Ever":EfanExtra#.pod]
      EfanLibrariesImpl.verifyLibNames(libs)
    }

    verifyEfanErrMsg(ErrMsgs.libraryNameNotValid("69Dude")) {
      libs := ["69Dude":EfanExtra#.pod]
      EfanLibrariesImpl.verifyLibNames(libs)
    }
  }

}