
internal class TestLookNoTemplate : EfanTest {

	Void testLookNoTemplate() {
		text := efanExtra.render(LookNoTemplate#)
		verifyEq(text, "Hello!")
	}
}
