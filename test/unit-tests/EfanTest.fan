using afIoc
using afEfan::EfanErr

internal class EfanTest : Test {
	Registry? reg
	ComponentCache? cache
	
	Void verifyEfanErrMsg(Str errMsg, |Obj| func) {
		verifyErrTypeMsg(EfanErr#, errMsg, func)
	}

	protected Void verifyErrTypeMsg(Type errType, Str errMsg, |Obj| func) {
		try {
			func(69)
		} catch (Err e) {
			if (!e.typeof.fits(errType)) 
				throw Err("Expected $errType got $e.typeof", e)
			msg := e.msg
			if (msg != errMsg)
				verifyEq(errMsg, msg)	// this gives the Str comparator in eclipse
			return
		}
		throw Err("$errType not thrown")
	}
	
	
	override Void setup() {
		reg 	= RegistryBuilder().addModules([AppModule#, EfanExtraModule#]).build.startup
		cache	= reg.dependencyByType(ComponentCache#)
	}

	override Void teardown() {
		reg?.shutdown
	}
}
