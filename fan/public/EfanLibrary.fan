using afIoc::Inject
using afEfan

** Use to manually render a component; an library instance exists for each contributed pod.
** 
** As well as the generic 'renderComponent()' method, libraries also have render methods for each individual component. 
** Example, if you had a component:
** 
** pre>
** const mixin CreamPie : EfanComponent {
**   @InitRender
**   Void initRender(Str x, Int y) { ... }
** }
** <pre
** 
** Then the corresponding library would define:
** 
**   Obj renderCreamPie(Str x, Int y, |Obj?|? bodyFunc := null) { ... }
** 
** Each library is automatically injected into your efan components as a field. The field has the same name as the 
** contribution. This allows you to group / namespace components in pods and distribute them as 3rd Party libraries. 
** Example, if 'CreamPie' was in a pod called 'pies', then if the 'pies' 'AppModule' contained: 
** 
** pre>
** using afIoc
** using afEfanExtra
** 
** class AppModule {
**   @Contribute { serviceType=EfanLibraries# }
**   static Void contributeEfanLibs(MappedConfig config) {
**     config["pies"] = Pod.find("pies")
**   }
** }
** <pre
** 
** Then any application that references the 'pies' pod automatically has the component 'pies.creamPie', which may be 
** rendered with:
** 
**   <% pies.renderCreamPie("cream", 69) %>
**    
const mixin EfanLibrary {

	** The name of library - given when you contribute a pod to 'EfanLibraries'. 
	abstract Str name
	
	@NoDoc	@Inject abstract ComponentCache	componentCache
	@NoDoc	@Inject abstract ComponentMeta	componentMeta
	
	** Renders the given efan component and returns the rendered Str. 
	** If the '@InitRender' method returns anything other than 'Void', 'null' or 'true', rendering is aborted and the 
	** value returned.
	Str renderComponent(Type comType, Obj?[] initArgs, |Obj?|? bodyFunc := null) {
		component 	:= componentCache.getOrMake(name, comType)

		renderBuf	:= (StrBuf?) null

		rendered 	:= RenderBufStack.push() |StrBuf renderBufIn -> Obj?| {
			return EfanRenderCtx.renderEfan(renderBufIn, (BaseEfanImpl) component, (|->|?) bodyFunc) |->Obj?| {
				ComponentCtx.push

				initRet := componentMeta.callMethod(comType, InitRender#, component, initArgs)
				
				// if init() returns false, cut rendering short
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
		if (rendered && (RenderBufStack.peek(false) == null))
			return renderBuf.toStr
		return Str.defVal
	}

	** Utility method to check if a set of parameters fit the component's [@InitRender]`InitRender` method.
	Bool fitsInitRender(Type comType, Type[] paramTypes) {
		initMethod := componentMeta.findMethod(comType, InitRender#)
		if (initMethod == null) {
			return paramTypes.isEmpty
		}
		return ReflectUtils.paramTypesFitMethodSignature(paramTypes, initMethod)
	}	
}
