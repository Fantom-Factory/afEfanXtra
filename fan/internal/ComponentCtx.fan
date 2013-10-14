using afIoc::ThreadStash
using afEfan::EfanRenderer
using afEfan::EfanRenderCtx
using concurrent::Actor

@NoDoc
class ComponentCtx {
	private [Str:[Str:Obj?]] stash	:= Utils.makeMap(Str#, [Str:Obj?]#)
	Str? tempId
	
	Void setVariable(Str name, Obj? value) {
		map[name] = value
	}
	
	Obj? getVariable(Str name) {
		map[name]
	}

	private Str:Obj? map() {
		key :=(tempId != null) ? tempId : EfanRenderCtx.currentNestedId 
		return stash.getOrAdd(key) { [Str:Obj?][:] }
	}

	// ---- static methods ----

	static Void withScope(EfanRenderer component, |->| func) {

		// TODO: we need to uniquely ID each component in a render stack and hold the variables in 
		get(true).tempId = EfanRenderCtx.deeperNestedId(component) 
		try {
			func.call
		} finally {
			get.tempId = null
		}
	}

	static ComponentCtx get(Bool make := false) {
		Actor.locals.getOrAdd("efanExtra.componentCtx") {
			make ? ComponentCtx() : throw Err("Could not find a ComponentCtx instance for 'efanExtra.componentCtx' on thread.")
		}
	}
}
