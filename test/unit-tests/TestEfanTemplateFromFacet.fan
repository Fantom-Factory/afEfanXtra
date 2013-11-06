
internal class TestEfanTemplateFromFacet : EfanTest {

	Void testTemplateInPod() {
		text := efanExtra.render(TemplateFromFacetInPod#)
		verifyEq(text, "EfanComponentPod.efan")
	}

	Void testTemplateOnFile() {
		text := efanExtra.render(TemplateFromFacetOnFile#)
		verifyEq(text, "EfanComponentFile.efan")
	}


	Void testTemplateInPodLocal() {
		text := efanExtra.render(TemplateFromFacetInPodLocal#)
		verifyEq(text, "EfanComponentPodLocal.efan")
	}
}