using afIoc::DependencyProvider
using afIoc::InjectionCtx
using concurrent::AtomicRef
using afIoc::Inject

internal const class LibraryProvider : DependencyProvider {

	@Inject private const EfanLibraries efanLibraries
	
	new make(|This|in) { in(this) }
	
	override Bool canProvide(InjectionCtx ctx) {
		efanLibraries.all.any { it.typeof.fits(ctx.dependencyType) }
	}

	override Obj? provide(InjectionCtx ctx) {
		efanLibraries.all.find { it.typeof.fits(ctx.dependencyType) }
	}
}
