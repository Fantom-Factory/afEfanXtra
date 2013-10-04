
@NoDoc
@Component
const mixin Layout {

	abstract Str? pageTitle

	 Void initialise(Str pageTitle) {
		this.pageTitle = pageTitle	
	 }
	
}
