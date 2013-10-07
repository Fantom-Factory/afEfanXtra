using afIoc::Inject
using afIoc::Registry
using afEfan::EfanErr

@NoDoc
const mixin EfanLibraries {

	abstract Str:Obj	libraries()
	
	abstract Type[]		componentTypes(Str library)
	
	abstract Type[]		libraryTypes()
}

internal const class EfanLibrariesImpl : EfanLibraries {
	
	private const Str:Pod 	libraryToPod
	private const Pod:Obj 	podToLibrary
	private const Str:Obj 	librariesF
		override Str:Obj 	libraries() { librariesF }

	@Inject	private	const Registry			registry
	@Inject	private	const ComponentFinder	componentFinder

	new make(Str:Pod libraries, LibraryCompiler libraryCompiler, Registry registry, |This|in) {
		in(this)

		libs := Utils.makeMap(Str#, Obj#)
		this.libraryToPod	= verifyLibNames(libraries)
		this.podToLibrary 	= libraries.map |pod, prefix| { 
			type 	:= libraryCompiler.compileLibrary(prefix, pod)
			lib		:= registry.autobuild(type)
			libs[prefix] = lib
			return lib
		}
		this.librariesF = libs.toImmutable
	}

	override Type[] componentTypes(Str library) {
		componentFinder.findComponentTypes(libraryToPod[library])
	}
	
	override Type[] libraryTypes() {
		podToLibrary.vals.map { it.typeof }
	}
	
	static Str:Pod verifyLibNames(Str:Pod libraries) {
		libraries.each |pod, libName| { if (!isFieldName(libName)) throw EfanErr(ErrMsgs.libraryNameNotValid(libName)) }
		return libraries
	}
	
	private static Bool isFieldName(Str s) {
		// @see http://fantom.org/sidewalk/topic/2193#c14128
		!s.isEmpty && (s[0].isAlpha || s[0] == '_') && s.all |c| { c.isAlphaNum || c == '_' }
	}	
}
