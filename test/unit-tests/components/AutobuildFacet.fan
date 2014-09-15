using afIoc

@NoDoc
const mixin AutobuildFacet : EfanComponent {
	
	@Autobuild abstract AutoStuff autoStuff
	
	override Str renderTemplate() { autoStuff.stuff }
}

@NoDoc
const class AutoStuff {
	const Str stuff := "Stuff"
}