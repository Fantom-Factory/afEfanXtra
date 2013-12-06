
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
