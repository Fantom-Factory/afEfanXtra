
@NoDoc @Component { }
const mixin T_InitFalseAborts {	
	Bool initRender() {
		false
	}
}

@NoDoc @Component { }
const mixin T_InitTrueOkay {	
	Bool initRender() {
		true
	}
}
