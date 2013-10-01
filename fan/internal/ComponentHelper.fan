using afIoc::Inject
using afIoc::Registry
using afIoc::ConcurrentCache

const class ComponentHelper {
	
//	@Inject
//	private const Registry registry
	
	// FIXME: make threaded
	private const ConcurrentCache vals	:= ConcurrentCache()
	
	new make(|This|in) { in(this) }
	
//	Obj service(Type serviceType) {
//		registry.dependencyByType(serviceType)
//	}
	
	Void setVariable(Str name, Obj value) {
		vals.set(name, value)
	}
	
	Obj getVariable(Str name) {
		vals.get(name)
	}
}
