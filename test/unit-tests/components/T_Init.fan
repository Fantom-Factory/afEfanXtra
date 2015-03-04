
@NoDoc
const mixin T_InitFalseAborts : EfanComponent {	
	Bool initRender() {
		false
	}
}

@NoDoc
const mixin T_InitTrueOkay : EfanComponent {
	Bool initRender() {
		true
	}
}

@NoDoc
const mixin T_InitReturnsObj : EfanComponent {
	Obj? initRender() {
		69
	}
}

@NoDoc
const mixin T_InitParams : EfanComponent {
	abstract Str? x
	abstract Int y
	
	Void initRender(Str? x, Int y) {
		this.x = x
		this.y = y
	}
}
