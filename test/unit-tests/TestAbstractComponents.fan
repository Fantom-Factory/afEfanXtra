
internal class TestAbstractComponents : EfanTest {
	
	Void testAbstractCompoentsDoNotExist() {
		// T_MyBaseComponent should not appear 'cos it has the @Abstract facet
		verifyFalse(efanExtra.componentTypes("app").contains(T_MyBaseComponent#))
	}
	
}
