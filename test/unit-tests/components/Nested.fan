
@NoDoc @Component
const mixin Nested {
	abstract Int n
	abstract Str text
	
	Void initRender(Int n) {
		this.n = n
	}
}
