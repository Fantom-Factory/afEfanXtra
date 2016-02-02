
internal class TestTemplateFromBaseType : EfanTest {

	Void testTemplateInPod() {
		text := render(TemplateFromBaseTypeSubclass#)
		verifyEq(text, "TemplateFromBaseType.efan")
	}
}