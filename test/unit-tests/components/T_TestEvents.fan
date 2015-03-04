using concurrent

@NoDoc
const mixin T_TestEvents : EfanComponent {
	
	@InitRender
	Void e1() {
		list.add("initRender")
	}

	@BeforeRender
	Void e2() {
		list.add("beforeRender")
	}

	@AfterRender
	Void e3() {
		list.add("afterRender")
	}

	private Str[] list() {
		Actor.locals["test"]
	}
}
