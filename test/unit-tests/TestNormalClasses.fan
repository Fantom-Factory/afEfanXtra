
internal class TestClasses : EfanTest {
	
	Void testClass() {
		text := render(T_NormalClass#, ["Dredd"])
		verifyEq(text, "I'm Norm! aka Dredd")
	}

	Void testConstClass() {
		text := render(T_NormalConstClass1#)
		verifyEq(text, "I'm Norm! aka Hershey")

		text = render(T_NormalConstClass2#, ["Hershey"])
		verifyEq(text, "I'm Norm! aka Hershey")
	}

	Void testMixin() {
		text := render(T_NormalMixin#, ["Anderson"])
		verifyEq(text, "I'm Norm! aka Anderson")
	}
}

@NoDoc
class T_NormalClass : EfanComponent {
	Str? name

	Void initRender(Str name) {
		this.name = name
	}
	
	override Str renderTemplate() {
		"I'm Norm! aka $name"
	}
}

@NoDoc
const class T_NormalConstClass1 : EfanComponent {
	const Str? name := "Hershey"

	override Str renderTemplate() {
		"I'm Norm! aka $name"
	}
}

@NoDoc
abstract const class T_NormalConstClass2 : EfanComponent {
	abstract Str? name

	Void initRender(Str name) {
		this.name = name
	}

	override Str renderTemplate() {
		"I'm Norm! aka $name"
	}
}

@NoDoc
mixin T_NormalMixin : EfanComponent {
	abstract Str? name

	Void initRender(Str name) {
		this.name = name
	}

	override Str renderTemplate() {
		"I'm Norm! aka $name"
	}
}
