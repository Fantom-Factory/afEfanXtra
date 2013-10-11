using afIoc
using afIocConfig::IocConfigModule
using afEfan::EfanErr
using afPlastic

internal class EfanTest : Test {
	Registry? reg
	EfanExtra?	efanExtra
	
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
		try {
		reg 		= RegistryBuilder().addModules([AppModule#, EfanExtraModule#, IocConfigModule#]).build.startup
		efanExtra	= reg.dependencyByType(EfanExtra#)
			
		} catch (PlasticCompilationErr pe) {
			err:=pe.print("Ooops", 50)
		Env.cur.err.printLine(err)
		}
	}

	override Void teardown() {
		reg?.shutdown
	}
}
