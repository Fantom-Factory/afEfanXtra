
internal class TestTemplateFromFacet : EfanTest {

	Void testTemplateInPod() {
		text := render(TemplateFromFacetInPod#)
		verifyEq(text, "EfanComponentPod.efan")
	}

	Void testTemplateOnFile() {
		text := render(TemplateFromFacetOnFile#)
		verifyEq(text, "EfanComponentFile.efan")
	}


	Void testTemplateInPodLocal() {
		text := render(TemplateFromFacetInPodLocal#)
		verifyEq(text, "EfanComponentPodLocal.efan")
	}
}