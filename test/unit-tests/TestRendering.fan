using afIoc
using afPlastic

internal class TestRendering : EfanTest {

	Void testNestedRendering() {
		try {
					
		html := efanExtra.render(Page#)
		verify(html.contains("<title>My Meat</title>"))
		verify(html.contains("<p>My Page</p>"))
			
		} catch (Err e) {
			Env.cur.err.printLine( Utils.traceErr(e) )
			throw e
		}
	}

	Void testServiceInjection() {
		html := efanExtra.render(Page#)
		verify(html.contains("<h1>Alien-Factory 69</h1>"))
	}

}
