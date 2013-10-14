
internal class TestVarsInBody : EfanTest {

	Void testVariablesAreAvailibleInBody() {

		text := efanExtra.render(Page2#)
		Env.cur.err.printLine(text)
		verify(text.contains("'Judge Dredd'"), text)
		
		// now test the body is rendered in the correct place
		
s := """page-start
        
        layout-start
        'Judge Dredd'
        
        layout-end
        page-end"""		
		verifyEq(text, s)
	}
}