
internal class TestLookNoTemplate : EfanTest {

	Void testLookNoTemplate() {
		text := efanXtra.render(LookNoTemplate#)
		verifyEq(text, "Hello!")
	}
	
	Void testTwoComponentsCanUseTheSameTemplate() {
		text := efanXtra.render(LookNoTemplate#)
		verifyEq(text, "Hello!")

		text = efanXtra.render(LookNoTemplateAgain#)
		verifyEq(text, "Hello! Me again!")
	}
}
