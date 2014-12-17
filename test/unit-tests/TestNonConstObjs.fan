using afIoc
using afIocConfig

internal class TestNonConstObjs : EfanTest {

	Void testNonConstFields() {
		text := render(T_NonConstFields#)
		verifyEq(text, "Non-Const Field!")
	}

	Void testNonConstService() {
		text := render(T_NonConstService#)
		verifyEq(text, "Non-Const Service!")
	}

	Void testLogFields() {
		text := render(T_LogFields#)
		verifyEq(text, "Wotever")
	}

	override Void setup() {
		Pod.find("afIoc")		.log.level = LogLevel.warn
		Pod.find("afEfanXtra")	.log.level = LogLevel.warn

		reg	= RegistryBuilder().addModules([EfanAppModule#, ConfigModule#, TestNonConstObjs#]).build.startup
		reg.injectIntoFields(this)
	}

	static Void defineServices(ServiceDefinitions defs) {
		defs.add(NonConstService#)
	}
}



@NoDoc
const mixin T_NonConstFields : EfanComponent {
	abstract StrBuf buf
	@InitRender
	Void initRender()				{ buf = StrBuf().add("Non-Const Field!") }
	override Str renderTemplate()	{ buf.toStr }
}

@NoDoc
const mixin T_NonConstService : EfanComponent {
	@Inject abstract NonConstService service
	override Str renderTemplate() { service.toStr }
}

@NoDoc
const mixin T_LogFields : EfanComponent {
	@Inject abstract Log log
	override Str renderTemplate() { log.info("Hello!"); return "Wotever" }
}

@NoDoc
class NonConstService {
	override Str toStr() { "Non-Const Service!" }
}
