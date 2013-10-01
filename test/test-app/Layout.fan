
@NoDoc
const mixin Layout : Component {

	abstract Str? pageTitle

	 Void initialise(Str pageTitle) {
		this.pageTitle = pageTitle	
	 }
	
}
