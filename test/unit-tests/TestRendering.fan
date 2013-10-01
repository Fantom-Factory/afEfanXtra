using afIoc

internal class TestRendering : EfanTest {

	Void testNestedRendering() {
		html := cache.createInstance(Page#).render(null)
		verify(html.contains("<title>My Meat</title>"))
		verify(html.contains("<p>My Page</p>"))
	}

	Void testServiceInjection() {
		html := cache.createInstance(Page#).render(null)
		verify(html.contains("<h1>Alien-Factory 69</h1>"))
	}

}
