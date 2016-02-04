
internal class TestTemplateFromTypeFandoc : EfanTest {
	
	Void testTemplateInFandocAll() {
		text := render(TemplateFromTypeFandocAll#)
		verifyEq(text, "Yo Dawg! Check this out!\n")
	}

	Void testTemplateInFandocSelective() {
		text := render(TemplateFromTypeFandocSelective#)
		verifyEq(text, "Yo Diggy! Check this out!\n")
	}

	Void testEmptyTemplateInFandoc() {
		text := render(TemplateFromTypeFandocEmpty#)
		verifyEq(text, "")
	}
}


** template: efan
** 
** Yo Dawg! Check <%= hello %>
** 
@NoDoc
const mixin TemplateFromTypeFandocAll : EfanComponent {
	Str hello() { "this out!" }
}

** This is not rendered.
** 
** pre>
** template: efan
** 
** Yo Diggy! Check <%= hello %>
** <pre
** 
** Nor is this
@NoDoc
const mixin TemplateFromTypeFandocSelective : EfanComponent {
	Str hello() { "this out!" }
}

**   template: efan
@NoDoc
const mixin TemplateFromTypeFandocEmpty : EfanComponent { }

