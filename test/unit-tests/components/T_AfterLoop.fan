
@NoDoc @Component { }
const mixin T_AfterLoop {
	abstract Int? loopy
	
	Void initRender() {
		loopy = 1
	}
	
	Bool afterRender() {
		loopy++ == 3
	}
}

