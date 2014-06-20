using afIoc
using afIocConfig::IocConfigModule
using afIocEnv
using afEfan::EfanErr
using afPlastic

internal class EfanTest : Test {
	@Inject Registry? 		reg
	@Inject EfanXtra?		efanXtra
	@Inject EfanLibraries?	efanLibs
	
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
	
	protected Str render(Type comType, Obj?[]? initArgs := null) {
		efanXtra.component(comType).render(initArgs)
	}
	
	override Void setup() {
		try {
			reg = RegistryBuilder().addModules([EfanAppModule#, IocConfigModule#, IocEnvModule#]).build.startup
			reg.injectIntoFields(this)
			
		} catch (PlasticCompilationErr pce) {
			Env.cur.err.printLine(pce.print("Ooops", 50))
			throw pce
		}
	}

	override Void teardown() {
		reg?.shutdown
	}
}
