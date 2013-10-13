using concurrent::Actor

internal class CallStack {
	private const 	Str 	stackName
	private 		Obj[] 	stack := [,]
	
	private new make(Str stackName) {
		this.stackName = stackName
	}
	
	private Obj? _call(Obj stackable, |->Str| func) {
		stack.push(stackable)

		try {
			return func()

		} finally {
			stack.pop
			if (stack.isEmpty)
				Actor.locals.remove(stackName)
		}
	}

	static Str pushAndRun(Str stackName, Obj stackable, |->Str| func) {
		get(stackName, true)._call(stackable, func)
	}
	
	static Obj peek(Str stackName, Int i := -1) {
		get(stackName, false).stack[i]
	}	

	private static CallStack get(Str stackName, Bool make := false) {
		Actor.locals.getOrAdd(stackName) { make ? CallStack(stackName) : throw Err("Could not find a CallStack instance for '${stackName}' on thread.") }
	}	
}
