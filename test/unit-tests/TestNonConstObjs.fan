using afIoc
using afIocConfig

internal class TestNonConstObjs : EfanTest {

	Void testNonConstFields() {
		text := efanXtra.render(T_NonConstFields#)
		verifyEq(text, "Non-Const Field!")
	}

	Void testNonConstService() {
		text := efanXtra.render(T_NonConstService#)
		verifyEq(text, "Non-Const Service!")
	}

	Void testLogFields() {
		text := efanXtra.render(T_LogFields#)
		verifyEq(text, "Wotever")
	}

	override Void setup() {
		reg 		= RegistryBuilder().addModules([EfanAppModule#, IocConfigModule#, TestNonConstObjs#]).build.startup
		efanXtra	= reg.dependencyByType(EfanXtra#)
	}

	static Void bind(ServiceBinder binder) {
		binder.bind(NonConstService#)
	}
}



@NoDoc
@EfanTemplate { uri=`fan://afEfanXtra/res/viaRenderMethod.efan`}
const mixin T_NonConstFields : EfanComponent {
	abstract StrBuf buf
	@InitRender
	Void initRender()	{ buf = StrBuf().add("Non-Const Field!") }
	Str render() 		{ buf.toStr }
}

@NoDoc
@EfanTemplate { uri=`fan://afEfanXtra/res/viaRenderMethod.efan`}
const mixin T_NonConstService : EfanComponent {
	@Inject abstract NonConstService service
	Str render() { service.toStr }
}

@NoDoc
@EfanTemplate { uri=`fan://afEfanXtra/res/viaRenderMethod.efan`}
const mixin T_LogFields : EfanComponent {
	@Inject abstract Log log
	Str render() { log.info("Hello!"); return "Wotever" }
}

class NonConstService {
	override Str toStr() { "Non-Const Service!" }
}
