using afIoc::Inject
using afEfan

@NoDoc
const mixin EfanLibrary {

	abstract Str name
	
	@NoDoc	@Inject abstract ComponentCache	componentCache
	@NoDoc	@Inject abstract ComponentMeta	componentMeta

	// TODO: fitsInitRenderMethod(...)
	
	Obj? renderComponent(Type comType, Obj[] initArgs, |Obj?|? bodyFunc := null) {
		component 	:= componentCache.getOrMake(name, comType)

		renderBuf	:= (StrBuf?) null

		rendered 	:= RenderBufStack.push() |StrBuf renderBufIn -> Obj?| {
			return EfanRenderCtx.renderEfan(renderBufIn, (BaseEfanImpl) component, (|->|?) bodyFunc) |->Obj?| {
				ComponentCtx.push

				initRet := componentMeta.callMethod(comType, InitRender#, component, initArgs)
				if (initRet != null && initRet.typeof != Bool#)
					return initRet
				
				// technically this is correct, but I'm wondering if I should return an empty Str instead???
				if (initRet == false)
					return initRet

				renderLoop := true
				while (renderLoop) {
					
					b4Ret	:= componentMeta.callMethod(comType, BeforeRender#, component, [renderBufIn])
					if (b4Ret != false)
						((BaseEfanImpl) component)._af_render(null)
					
					aftRet	:= componentMeta.callMethod(comType, AfterRender#, component, [renderBufIn])
					
					renderLoop = (aftRet == false)
				}
				
				renderBuf = renderBufIn
				return true
			}
		}

		// if the stack is empty, return the result of rendering
		if (rendered == true)
			return (RenderBufStack.peek(false) == null) ? renderBuf.toStr : Str.defVal
		return rendered
	}
}

const class A2 : BaseEfanImpl {
	
	override EfanMetaData efanMetaData {
		get { [,].first }
		set {}
	}
	
	override Void _af_render(Obj? _ctx) { }

}

//class Example {
//	
//	Void main() {
//		echo("sjsf")
//		renderEfan(A2(), (|->|?) null) |->Obj?| {
//			return true
//		}
//		Env.cur.err.printLine("done")
//	}
//	
//	static Obj? renderEfan(BaseEfanImpl rendering, |->|? bodyFunc, |->Obj?| func) {
////		EfanCtxStack.withCtx("") |EfanCtxStackElement element| {
//			return ((|Obj?|) func).call(69)
////		}
//	}
//}
