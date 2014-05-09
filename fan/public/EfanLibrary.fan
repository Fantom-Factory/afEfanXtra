using afIoc::Inject
using afEfan

** A library of efan components for a specific 'Pod'.
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
	
	** The pod this library represents - given when you contribute a pod to 'EfanLibraries'.
	abstract Pod pod
	
	** Returns the types of all the components in this library.
	Type[] componentTypes() {
		componentFinder.findComponentTypes(pod)
	}

	** Utility method to check if the given parameters will fit the component's [@InitRender]`InitRender` method.
//	Bool fitsInitRender(Type comType, Type[] paramTypes) {
//		initMethod := componentMeta.findMethod(comType, InitRender#)
//		if (initMethod == null) {
//			return paramTypes.isEmpty
//		}
//		return ReflectUtils.paramTypesFitMethodSignature(paramTypes, initMethod)
//	}
	
	** Called by library render methods. 
	** _Underscore_ 'cos there may be a component called 'Component' and we'd get a name clash
	@NoDoc
	Str _renderComponent(Type componentType, Obj?[] initArgs, |Obj?|? bodyFunc) {
		componentCache.getOrMake(componentType).renderTemplate(initArgs, (|->|?) bodyFunc)
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
