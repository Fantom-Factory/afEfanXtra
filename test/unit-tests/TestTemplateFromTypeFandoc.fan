
internal class TestTemplateFromTypeFandoc : EfanTest {
	
	Void testTemplateInFandoc() {
		text := render(TemplateFromTypeFandoc#)
		verifyEq(text.trim, "Yo Dawg! Check this out!")
	}

	Void testEmptyTemplateInFandoc() {
		text := render(TemplateFromTypeFandocEmpty#)
		verifyEq(text, "")
	}
}


** pre>
** template: efan
** 
** Yo Dawg! Check <%= hello %>
** <pre
@NoDoc
const mixin TemplateFromTypeFandoc : EfanComponent {
	Str hello() { "this out!" }
}

**   template: efan
@NoDoc
const mixin TemplateFromTypeFandocEmpty : EfanComponent { }

