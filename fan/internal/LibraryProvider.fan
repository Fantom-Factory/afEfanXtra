using afIoc::DependencyProvider
using afIoc::InjectionCtx
using concurrent::AtomicRef
using afIoc::Inject

internal const class LibraryProvider : DependencyProvider {

	@Inject private const EfanLibraries efanLibs
	
	new make(|This|in) { in(this) }
	
	override Bool canProvide(InjectionCtx ctx) {
		// Reuse the @Inject facet for field injection
		// Don't quiz, create services unless we have to
		ctx.injectionKind.isFieldInjection && ctx.field.hasFacet(Inject#) && ctx.dependencyType.fits(EfanLibrary#)
	}

	override Obj? provide(InjectionCtx ctx) {
		ctx.log("Injecting Log for ${ctx.injectingIntoType.qname}")
		libName	:= ((Inject?) ctx.fieldFacets.findType(Inject#).first).id
		return efanLibs[libName]
	}
}
