
@NoDoc
const mixin T_BeforeFalseAborts : EfanComponent {	
	Bool beforeRender() {
		false
	}
}

@NoDoc
const mixin T_BeforeTrueOkay : EfanComponent {	
	Bool? beforeRender() {
		true
	}
}

@NoDoc
const mixin T_BeforeNonBool : EfanComponent {	
	Int beforeRender() {
		69
	}
}

@NoDoc
const mixin T_AfterNonBool : EfanComponent {	
	Int afterRender() {
		69
	}
}
