using concurrent

internal class TestComponentsAreMutable : EfanTest {
	
	Void testComponentsAreMutable() {
		text := efanExtra.render(Mutable#)
		verify(text.contains("All change please!"))
	}
}
