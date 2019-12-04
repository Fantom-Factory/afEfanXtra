
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
@NoDoc @Deprecated	// move to ctx
class ComponentCtx {
	private [Str:Obj?] stash	:= Str:Obj?[:] { it.caseInsensitive = true }
	
	Void setVariable(Str name, Obj? value) {
		stash[name] = value
	}
	
	Obj? getVariable(Str name) {
		stash[name]
	}

	Bool hasVariable(Str name) {
		stash.containsKey(name)
	}

	override Str toStr() {
		stash.toStr
	}
}

@NoDoc @Deprecated
const class ComponentCtxMgr {
	ComponentCtx peek() {
		EfanRenderingStack.peek.ctx["efanXtra.componentCtx"]
	}
	
	Void createNew() {
		EfanRenderingStack.peek.ctx["efanXtra.componentCtx"] = ComponentCtx()
	}
}
