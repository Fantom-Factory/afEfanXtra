using afEfan::EfanRenderer

** Components are all about *rendering* the  
const mixin Component : EfanRenderer {
	
	virtual Void beforeRender() { }
	virtual Void afterRender() { }

	
	override This with(|This| f) {
		return this
	}
}
