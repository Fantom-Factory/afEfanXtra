
@NoDoc @Component { }
const mixin T_BeforeFalseAborts {	
	Bool initRender() {
		false
	}
}

@NoDoc @Component { }
const mixin T_BeforeTrueOkay {	
	Bool initRender() {
		true
	}
}
