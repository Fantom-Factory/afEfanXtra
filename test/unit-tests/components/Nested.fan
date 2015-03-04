
@NoDoc
const mixin Nested : EfanComponent {
	abstract Int n
	abstract Str text
	
	Void initRender(Int n) {
		this.n = n
	}
}
