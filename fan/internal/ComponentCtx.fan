using afEfan::EfanRenderer
using afEfan::EfanCtxStack

** This class stores all the component variables. Note this is trickier than you may first think!
** 
**  - We can't use the EfanRenderCtx because we need to be 'in the component ctx' during the 
** 'initRender()' method, which is called *before* we call efan.render().  
** 
**  - We can't use a simple map keyed off the component type because we may nest the same component,
**  resulting in an overwrite of values. e.g. MenuItem -> MenuItem
** 
** So we invented the EfanCtxStack - a reusable abstraction of nested components!
** 
@NoDoc
class ComponentCtx {
	private [Str:Obj?] stash	:= Utils.makeMap(Str#, Obj?#)
	
	Void setVariable(Str name, Obj? value) {
		stash[name] = value
	}
	
	Obj? getVariable(Str name) {
		stash[name]
	}

	override Str toStr() {
		stash.toStr
	}
	
	// ---- static methods ----

	static ComponentCtx peek() {
		EfanCtxStack.peek.ctx["efanXtra.componentCtx"]
	}
	
	static Void push() {
		EfanCtxStack.peek.ctx["efanXtra.componentCtx"] = ComponentCtx()
	}
	
	Void main(Str[] args) {
		echo(this.typeof.pod.version)
	}
	
}
