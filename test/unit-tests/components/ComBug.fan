using afEfan

@NoDoc
@Component
const mixin ComBug1 : EfanRenderer { 
	Void bug() {
		a:=efanMetaData.efanSrcCode
		Env.cur.err.printLine(a)
	}
}

@NoDoc
@Component
const mixin ComBug2 { }

@NoDoc
@Component
const mixin ComBug3 { }


