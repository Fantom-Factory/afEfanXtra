
@NoDoc
const mixin T_BeforeFalseAborts : EfanComponent {	
	Bool initRender() {
		false
	}
}

@NoDoc
const mixin T_BeforeTrueOkay : EfanComponent {	
	Bool initRender() {
		true
	}
}
