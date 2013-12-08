using concurrent

internal class TestEvents : EfanTest {
	
	Void testComponentsAreMutable() {
		list := Str[,]
		Actor.locals["test"] = list
		text := efanXtra.render(T_TestEvents#)
		verifyEq(list.join(", "), "initRender, beforeRender, afterRender")
	}

}
