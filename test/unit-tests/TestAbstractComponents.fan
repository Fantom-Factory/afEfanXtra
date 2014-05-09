using afIoc

internal class TestAbstractComponents : EfanTest {
	
	Void testAbstractCompoentsDoNotExist() {
		// T_MyBaseComponent should not appear 'cos it has the @Abstract facet
		verifyFalse(efanLibs.get("app").componentTypes.contains(T_MyBaseComponent#))
	}
	
}
