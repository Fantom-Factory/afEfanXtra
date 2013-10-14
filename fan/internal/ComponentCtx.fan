using afIoc::ThreadStash
using afEfan::EfanRenderer
using afEfan::EfanRenderCtx
using concurrent::Actor

@NoDoc
class ComponentCtx {
	internal static const Str localsKey	:= "efanExtra.componentCtx"
	
	private [Str:[Str:Obj?]] stash	:= Utils.makeMap(Str#, [Str:Obj?]#)
	private Str? tempId
	
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

	override Str toStr() {
		stash.toStr
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

	static Void cleanUp() {
		if (EfanRenderCtx.currentNestedId.isEmpty)
			Actor.locals.remove(localsKey)
	}
	
	static ComponentCtx get(Bool make := false) {
		Actor.locals.getOrAdd(localsKey) {
			make ? ComponentCtx() : throw Err("Could not find a ComponentCtx instance for '${localsKey}' on thread.")
		}
	}
}
