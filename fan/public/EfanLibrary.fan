using afIoc::Inject
using afEfan

** A library of efan components for a specific 'Pod'.
** 
** Libraries are created dynamically at runtime, and each one is injected into every efan component.
** They give templates an easy means to render other components.
** 
** Libraries are created / defined by contributing to 'EfanLibraries' in your 'AppModule'. 
** As a library represents all components in a specific 'pod', you contribute the 'pod' with a given name.
** 
** Example, here the pod 'afPies' is contributed with the name 'pies':
** 
** pre>
** syntax: fantom
** using afIoc
** using afEfanExtra
** 
** class AppModule {
**   @Contribute { serviceType=EfanLibraries# }
**   static Void contributeEfanLibs(Configuration config) {
**     config["pies"] = Pod.find("afPies")
**   }
** }
** <pre
** 
** If the pod 'afPies' defines a component named 'CreamPie':
** 
** pre>
** syntax: fantom
** const mixin CreamPie : EfanComponent {
**   @InitRender
**   Void initRender(Str x, Int y) { ... }
** }
** <pre
** 
** Then the 'pies' library would dynamically define the method:
** 
**   syntax: fantom
**   Str renderCreamPie(Str x, Int y, |->|? bodyFunc := null) { ... }
** 
** Every library is injected into every efan component as a field. The field has the same name as 
** the library contribution. 
** This means that *any* component can render a 'creamPie' in it's template with the efan code:
**
**   <% pies.renderCreamPie("jam", 7) %>
**  
** This makes it very easy to nest / render components inside other components.
** 
** Libraries are a great way to group / namespace components in pods and distribute them as 
** 3rd Party libraries.
const mixin EfanLibrary {

	@NoDoc	@Inject abstract ComponentCache		componentCache
	@NoDoc	@Inject	abstract ComponentFinder	componentFinder
	
	** The name of this library - given when you contribute a pod to 'EfanLibraries'. 
	abstract Str name
	
	** The pod this library represents - given when you contribute a pod to 'EfanLibraries'.
	abstract Pod pod
	
	** Returns the types of all the components in this library.
	Type[] componentTypes() {
		componentFinder.findComponentTypes(pod)
	}
	
	** Called by library render methods --> app.renderMe() { _renderComponent(Me#) }
	** _Underscore_ 'cos there may be a component called 'Component' and we'd get a name clash
	@NoDoc
	Str _renderComponent(Type componentType, Obj?[] initArgs, |Obj?|? bodyFunc) {
		componentCache.getOrMake(componentType).render(initArgs, (|->|?) bodyFunc)
	}
}
