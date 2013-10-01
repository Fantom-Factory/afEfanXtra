using afIoc::DependencyProvider
using afIoc::ProviderCtx
using concurrent::AtomicRef
using afIoc::Inject

internal const class ComponentsProvider : DependencyProvider {
	
	const AtomicRef libs	:= AtomicRef(Type#.emptyList)
	
	new make(|This|in) { in(this) }
	
	override Bool canProvide(ProviderCtx ctx, Type dependencyType) {
		// FIXME: update afIoc docs for this - cannot call out to other services
		((Obj[]) libs.val).any { it.typeof.fits(dependencyType) }
	}

	override Obj? provide(ProviderCtx ctx, Type dependencyType) {
		((Obj[]) libs.val).find { it.typeof.fits(dependencyType) }
	}
	
}
