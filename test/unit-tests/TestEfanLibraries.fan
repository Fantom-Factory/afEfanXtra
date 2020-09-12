using afIoc::Configuration
using afIoc::RegistryBuilder

internal class TestEfanLibraries : EfanTest {

	override Void setup() {
		Pod.find("afIoc")		.log.level = LogLevel.warn
		Pod.find("afIocEnv")	.log.level = LogLevel.warn
		Pod.find("afEfanXtra")	.log.level = LogLevel.warn
	}
	
	Void testLibNamesMustBeValid() {

		verifyEfanErrMsg("Efan Library name is not valid. It must be a legal Fantom name : Wot Ever") {
			libs := ["Wot Ever":Pod.of(this)]
			EfanLibrariesImpl.verifyLibNames(libs)
		}

		verifyEfanErrMsg("Efan Library name is not valid. It must be a legal Fantom name : 69Dude") {
			libs := ["69Dude":Pod.of(this)]
			EfanLibrariesImpl.verifyLibNames(libs)
		}
	}

	Void testDoubleLibs() {
		// Given
		reg = RegistryBuilder()
			.addModulesFromPod("afEfanXtra")
			.addModule(EfanAppModule#)
			.contributeToServiceType(EfanLibraries#) |Configuration config| {
				config["foo"] = EfanAppModule#.pod
				config["bar"] = EfanAppModule#.pod
			}
			.build
		reg.rootScope.inject(this)
			
		// When
		// Bugfix - Err: Duplicate slot name 'foo'
		str := efanXtra.component(SignOff#).render(["Judge Dredd"])
		
		// Then
		verifyEq(str, "Yours faithfully,\n\nJudge Dredd\n")
	}
}
