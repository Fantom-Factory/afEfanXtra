
internal class TestUsingComPod : EfanTest {

	Void testCanUseTypesInDefiningPod() {
		text := render(T_UsingComPod#)
		verifyEq(text, "Eight Legged Freaks!")
	}
	
}

@NoDoc
const class T_UsingComPodState {
	override Str toStr() {
		"Eight Legged Freaks!"
	}
}