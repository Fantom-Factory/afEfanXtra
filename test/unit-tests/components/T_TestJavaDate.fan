using [java] java.util::Date as JDate

@NoDoc
const mixin T_TestJavaDate : EfanComponent {
	abstract JDate jdate
	override Str renderTemplate() { "" }
}
