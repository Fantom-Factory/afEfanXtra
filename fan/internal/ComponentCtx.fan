using afIoc::ThreadStash

@NoDoc
class ComponentCtx {
	private [Str:Obj?] stash	:= Utils.makeMap(Str#, Obj?#)
	
	Void setVariable(Str name, Obj? value) {
		stash.set(name, value)
	}
	
	Obj? getVariable(Str name) {
		stash.get(name)
	}
	
	// ---- static methods ----
	
	static Str renderComponent(|->Str| func) {
		// TODO: we need to uniquely ID each component in a render stack and hold the variables in 
		// ONE thread-stash. Then components can be passed into other components. Take from MetaData???
		stash := ThreadStash("efanExtra.componentVariables")
		try {
			return CallStack.pushAndRun("efanExtra.renderCtx", stash, func)
		} finally {
			stash.clear
		}
	}

	static ComponentCtx peek() {
		CallStack.peek("efanExtra.componentCtx")
	}
}
