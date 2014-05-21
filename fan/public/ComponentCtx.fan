using afConcurrent
using afIoc
using afEfan

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
}

@NoDoc
const class ComponentCtxMgr {
	private const LocalRef			injectedCtx
	
	new make(ThreadLocalManager	threadLocalMgr) {
		injectedCtx = threadLocalMgr.createRef("efanXtra.componentCtx")
	}
	
	ComponentCtx peek() {
		EfanRenderingStack.peek.ctx["efanXtra.componentCtx"]
	}
	
	Void createNew() {
		ctx := injectedCtx.isMapped ? injectedCtx.val : ComponentCtx() 
		EfanRenderingStack.peek.ctx["efanXtra.componentCtx"] = ctx
		injectedCtx.cleanUp
	}

	Void inject(ComponentCtx ctx) {
		injectedCtx.val = ctx
	}
}
