
internal class TestLookNoTemplate : EfanTest {

	Void testLookNoTemplate() {
		text := efanXtra.render(LookNoTemplate#)
		verifyEq(text, "Hello!")
	}
}
