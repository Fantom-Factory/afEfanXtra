using afIoc

internal class TestAbstractComponents : EfanTest {
	
	Void testAbstractCompoentsDoNotExist() {
		// T_MyBaseComponent should not appear 'cos it has the @Abstract facet
		verifyFalse(efanLibs["app"].componentTypes.contains(T_MyBaseComponent#))

		// Nor this 'cos it is an abstract class
		// Okay - it *could* be a component, but why should it!?
		verifyFalse(efanLibs["app"].componentTypes.contains(T_MyBaseComponent2#))
	}
	
}
