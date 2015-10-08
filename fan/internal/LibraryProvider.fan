using afIoc::DependencyProvider
using afIoc::InjectionCtx
using afIoc::Scope
using afIoc::Inject
using concurrent::AtomicRef

internal const class LibraryProvider : DependencyProvider {

	@Inject private const EfanLibraries efanLibs
	
	new make(|This|in) { in(this) }
	
	override Bool canProvide(Scope scope, InjectionCtx ctx) {
		// Reuse the @Inject facet for field injection
		// Don't quiz, create services unless we have to
		ctx.isFieldInjection && ctx.field.hasFacet(Inject#) && ctx.field.type.fits(EfanLibrary#)
	}

	override Obj? provide(Scope scope, InjectionCtx ctx) {
		libName	:= ((Inject?) ctx.field.facets.findType(Inject#).first).id
		return efanLibs[libName]
	}
}
