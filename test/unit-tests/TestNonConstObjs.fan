using afIoc
using afIocConfig
using afPlastic::PlasticModule
using afConcurrent::ConcurrentModule

internal class TestNonConstObjs : EfanTest {

	Void testNonConstFields() {
		reg.rootScope.createChildScope("thread") {
			text := render(T_NonConstFields#)
			verifyEq(text, "Non-Const Field!")
		}
	}

	Void testConstService() {
		text := render(T_ConstService#)
		verifyEq(text, "Const Service!")
	}

	Void testNonConstService() {
		reg.rootScope.createChildScope("thread") {
			text := render(T_NonConstService#)
			verifyEq(text, "Non-Const Service!")
		}
	}

	Void testLogFields() {
		reg.rootScope.createChildScope("thread") {
			text := render(T_LogFields#)
			verifyEq(text, "Wotever")
		}
	}

	override Void setup() {
		Pod.find("afIoc")		.log.level = LogLevel.warn
		Pod.find("afEfanXtra")	.log.level = LogLevel.warn

		reg	= RegistryBuilder() {
			addModules([EfanAppModule#, IocConfigModule#, IocConfigModule#, ConcurrentModule#, PlasticModule#])
			addService(MyConstService#).withScope("root")
			addService(MyNonConstService#).withScope("thread")
			addScope("thread")
		}.build
		reg.rootScope.inject(this)
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
const mixin T_ConstService : EfanComponent {
	@Inject abstract MyConstService service
	override Str renderTemplate() { service.toStr }
}

@NoDoc
const mixin T_NonConstService : EfanComponent {
	@Inject abstract MyNonConstService service
	override Str renderTemplate() { service.toStr }
}

@NoDoc
const mixin T_LogFields : EfanComponent {
	@Inject abstract Log log
	override Str renderTemplate() { log.info("Hello!"); return "Wotever" }
}

@NoDoc
class MyNonConstService {
	override Str toStr() { "Non-Const Service!" }
}

@NoDoc
const class MyConstService {
	override Str toStr() { "Const Service!" }
}
