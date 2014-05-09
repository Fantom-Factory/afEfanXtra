using afIoc
using afIocConfig

internal class TestIocConfig : EfanTest {

	Void testCanInjectIocConfigValues() {
		text := render(T_IocConfig#)
		// I don't really care for the value, just that it gets injected.
		verifyEq(text, "EfanComponentImpl")
	}

}

@NoDoc
@EfanTemplate { uri=`fan://afEfanXtra/res/viaRenderMethod.efan`}
const mixin T_IocConfig : EfanComponent {
	@Inject @Config { id="afEfan.rendererClassName" }
	abstract Str classname
	
	Str render() { classname }
}
