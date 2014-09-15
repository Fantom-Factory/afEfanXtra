
internal class TestAutobuildFacet : EfanTest {

	Void testAutobuild() {
		text := render(AutobuildFacet#)
		verify(text.contains("Stuff"))
	}
}
