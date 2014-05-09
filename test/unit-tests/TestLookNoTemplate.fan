
internal class TestLookNoTemplate : EfanTest {

	Void testLookNoTemplate() {
		text := render(LookNoTemplate#)
		verifyEq(text, "Hello!")
	}
	
	Void testTwoComponentsCanUseTheSameTemplate() {
		text := render(LookNoTemplate#)
		verifyEq(text, "Hello!")

		text = render(LookNoTemplateAgain#)
		verifyEq(text, "Hello! Me again!")
	}
}
