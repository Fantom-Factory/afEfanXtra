using afIoc::ThreadStash

@NoDoc	// TODO: rename to ComponentVariables or ComponentStash / turn into a mixin
const class ComponentHelper {
	
	Void setVariable(Str name, Obj value) {
		stash.set(name, value)
	}
	
	Obj getVariable(Str name) {
		stash.get(name)
	}
	
	Void scopeVariables(|->| func) {
		// TODO: we need to uniquely ID each component in a render stack and hold the variables in 
		// ONE thread-stash. Then components can be passed into other components. Take from MetaData???
		stash := ThreadStash("efanExtra.componentVariables")
		try {
			CallStack.call("efanExtra.renderCtx", stash, func)
		} finally {
			stash.clear
		}
	}
	
	private ThreadStash stash() {
		CallStack.stackable("efanExtra.renderCtx")
	}
}
