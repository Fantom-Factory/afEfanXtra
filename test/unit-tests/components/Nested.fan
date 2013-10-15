
@NoDoc
@Component
const mixin Nested {
	abstract Int n
	abstract Str text
	
	Void initialise(Int n) {
		this.n = n
	}
}
