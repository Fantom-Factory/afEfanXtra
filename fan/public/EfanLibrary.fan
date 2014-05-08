using afIoc::Inject
using afEfan

** A library of efan components; use to manually render a component.
** A library instance exists for each contributed pod.
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
**   <% pies.renderCreamPie("cream", 7) %>
**    
const mixin EfanLibrary {

	@NoDoc	@Inject abstract ComponentCache		componentCache
	@NoDoc	@Inject abstract ComponentMeta		componentMeta
	@NoDoc	@Inject	abstract ComponentFinder	componentFinder
	
	** The name of library - given when you contribute a pod to 'EfanLibraries'. 
	abstract Str name
	
	// FIXME !
	** The pod this library represents - given when you contribute a pod to 'EfanLibraries'.
	abstract Pod pod
	
	** Returns the types of all the components in this library.
	Type[] componentTypes() {
		componentFinder.findComponentTypes(pod)
	}
	
	// a public render method without the confusing 'bodyFunc' parameter
	** Renders the given efan component and returns the rendered Str. 
	** All lifecycle methods are honoured - '@InitRender', '@BeginRender' and '@AfterRender'.
	Str renderComponent(Type componentType, Obj?[]? initArgs := null) {
		_renderComponent(componentType, initArgs ?: Obj#.emptyList, null)
	}

	** Utility method to check if the given parameters will fit the component's [@InitRender]`InitRender` method.
	Bool fitsInitRender(Type comType, Type[] paramTypes) {
		initMethod := componentMeta.findMethod(comType, InitRender#)
		if (initMethod == null) {
			return paramTypes.isEmpty
		}
		return ReflectUtils.paramTypesFitMethodSignature(paramTypes, initMethod)
	}
	
	** Called by library render methods
	** _Underscore_ 'cos there may be a component called 'Component' and we'd get a name clash
	@NoDoc
	Str _renderComponent(Type componentType, Obj?[] initArgs, |Obj?|? bodyFunc) {
		component 	:= componentCache.getOrMake(componentType)

		renderBuf	:= (StrBuf?) null

		rendered 	:= RenderBufStack.push() |StrBuf renderBufIn -> Obj?| {
			return EfanRenderCtx.renderEfan(renderBufIn, (BaseEfanImpl) component, (|->|?) bodyFunc) |->Obj?| {
				ComponentCtx.push

				initRet := componentMeta.callMethod(InitRender#, component, initArgs)
				
				// if init() returns false, cut rendering short
				if (initRet == false)
					return initRet

				renderLoop := true
				while (renderLoop) {

					b4Ret	:= componentMeta.callMethod(BeforeRender#, component, [renderBufIn])
					if (b4Ret != false)
						((BaseEfanImpl) component)._af_render(null)
					
					aftRet	:= componentMeta.callMethod(AfterRender#, component, [renderBufIn])
					
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
	
	@NoDoc
	Obj? callMethod(Type comType, Obj?[] initArgs, |->Obj?| func) {
		component 	:= componentCache.getOrMake(comType)
		rendering	:= (BaseEfanImpl) component
		return EfanCtxStack.withCtx(rendering.efanMetaData.templateId) |EfanCtxStackElement element->Obj?| {
			ComponentCtx.push
			componentMeta.callMethod(InitRender#, component, initArgs)			
			return func.call
		}
	}
}
