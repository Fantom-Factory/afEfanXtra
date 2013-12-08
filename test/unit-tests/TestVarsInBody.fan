
internal class TestVarsInBody : EfanTest {

	Void testVariablesAreAvailibleInBody() {
		afEfan::EfanRenderer#.pod.log.level = LogLevel.debug
		
		text := efanXtra.render(Page2#).toStr
//		Env.cur.err.printLine("[${text}]")
		verify(text.contains("'Judge Dredd'"), text)
		
		// now test the body is rendered in the correct place
		
s := """page-start
        layout-start
        
        'Judge Dredd'
        
        layout-end
        page-end"""

		verifyEq(text, s)

		afEfan::EfanRenderer#.pod.log.level = LogLevel.info
	}
	
	Void testNastyNesting() {
//		afEfan::EfanRenderer#.pod.log.level = LogLevel.debug
		text := efanXtra.render(Nested#, [3]).toStr
//		Env.cur.err.printLine("[${text}]")
		
		i1 := text.index("start-3")
		i2 := text.index("start-2")
		verify(i2 > i1)

		i1 = text.index("start-2")
		i2 = text.index("start-1")
		verify(i2 > i1)

		i1 = text.index("body-3")
		i2 = text.index("body-2")
		verify(i2 > i1)
		
		i1 = text.index("3 little piggy")
		i2 = text.index("2 little piggy")
		verify(i2 > i1)
		
//		afEfan::EfanRenderer#.pod.log.level = LogLevel.info
	}
}