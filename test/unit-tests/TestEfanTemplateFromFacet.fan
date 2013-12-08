
internal class TestEfanTemplateFromFacet : EfanTest {

	Void testTemplateInPod() {
		text := efanXtra.render(TemplateFromFacetInPod#)
		verifyEq(text, "EfanComponentPod.efan")
	}

	Void testTemplateOnFile() {
		text := efanXtra.render(TemplateFromFacetOnFile#)
		verifyEq(text, "EfanComponentFile.efan")
	}


	Void testTemplateInPodLocal() {
		text := efanXtra.render(TemplateFromFacetInPodLocal#)
		verifyEq(text, "EfanComponentPodLocal.efan")
	}
}