
internal class TestFandocRendering : EfanTest {

	Void testBasicFandocRendering() {
		text := render(T_ComFandoc1#)
		verifyEq(text, "\n<h3>Look ma, Fandoc rendering: \n<p>T_ComFandoc2</p>\n</h3>\n")
	}
	
}
