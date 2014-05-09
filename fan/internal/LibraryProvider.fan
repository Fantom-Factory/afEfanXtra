using afIoc::DependencyProvider
using afIoc::InjectionCtx
using concurrent::AtomicRef
using afIoc::Inject

internal const class LibraryProvider : DependencyProvider {

	@Inject private const EfanXtra efanXtra
	
	new make(|This|in) { in(this) }
	
	override Bool canProvide(InjectionCtx ctx) {
		efanXtra.libraries.any { it.typeof.fits(ctx.dependencyType) }
	}

	override Obj? provide(InjectionCtx ctx) {
		efanXtra.libraries.find { it.typeof.fits(ctx.dependencyType) }
	}
}
