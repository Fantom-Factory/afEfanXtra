using concurrent

internal class TestComponentsAreMutable : EfanTest {
	
	Void testComponentsAreMutable() {
		text := efanExtra.render(Mutable#).toStr
		verify(text.contains("All change please!"))
	}
}
