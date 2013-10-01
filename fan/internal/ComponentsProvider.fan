using afIoc::DependencyProvider
using afIoc::ProviderCtx
using concurrent::AtomicRef
using afIoc::Inject

//@NoDoc
//const mixin ComponentsProvider : DependencyProvider { }
//
//@NoDoc
//const class ComponentsProviderImpl : ComponentsProvider {
const class ComponentsProvider : DependencyProvider {
	
//	const AtomicRef types	:= AtomicRef(Type#.emptyList)
	const AtomicRef libs	:= AtomicRef(Type#.emptyList)
	
	new make(|This|in) { in(this) }
	
	override Bool canProvide(ProviderCtx ctx, Type dependencyType) {
		// FIXME: update afIoc docs for this - cannot call out to other services
//		registryStarted.val ? efanLibraries.libraryTypes.contains(dependencyType) : false
//		((Type[]) types.val).contains(dependencyType)
		((Obj[]) libs.val).any { it.typeof.fits(dependencyType) }
	}

	override Obj? provide(ProviderCtx ctx, Type dependencyType) {
		((Obj[]) libs.val).find { it.typeof.fits(dependencyType) }
	}
	
}
