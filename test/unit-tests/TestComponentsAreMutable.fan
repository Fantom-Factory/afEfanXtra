using concurrent

internal class TestComponentsAreMutable : EfanTest {
	
	Void testComponentsAreMutable() {
		text := efanXtra.render(Mutable#).toStr
		verify(text.contains("All change please!"))
	}
}
