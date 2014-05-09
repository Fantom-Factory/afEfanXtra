using concurrent

internal class TestComponentsAreMutable : EfanTest {
	
	Void testComponentsAreMutable() {
		text := render(Mutable#)
		verify(text.contains("All change please!"))
	}
}
