
internal class TestJavaDate : EfanTest {

	Void testJavaDate() {
		text := render(T_TestJavaDate#)
		verifyEq(text, "")
	}
}
