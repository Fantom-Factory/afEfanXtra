using afIoc
using afIocConfig

internal class TestIocConfig : EfanTest {

	Void testCanInjectIocConfigValues() {
		text := render(T_IocConfig#)
		// I don't really care for the value, just that it gets injected.
		verifyEq(text, "2sec")
	}
}

@NoDoc
const mixin T_IocConfig : EfanComponent {
	@Inject @Config { id="afEfanXtra.templateTimeout" }
	abstract Duration timeout
	
	override Str renderTemplate() { timeout.toStr }
}
