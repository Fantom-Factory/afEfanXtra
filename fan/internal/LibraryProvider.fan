using afIoc::DependencyProvider
using afIoc::ProviderCtx
using concurrent::AtomicRef
using afIoc::Inject

internal const class LibraryProvider : DependencyProvider {

	@Inject private const EfanLibraries efanLibraries
	
	new make(|This|in) { in(this) }
	
	override Bool canProvide(ProviderCtx ctx, Type dependencyType) {
		efanLibraries.libraries.vals.any { it.typeof.fits(dependencyType) }
	}

	override Obj? provide(ProviderCtx ctx, Type dependencyType) {
		efanLibraries.libraries.vals.find { it.typeof.fits(dependencyType) }
	}
}
