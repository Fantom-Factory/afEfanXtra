using afIoc::Inject
using afIoc::Registry
using afEfan::EfanErr

@NoDoc
const mixin EfanLibraries {

	abstract Str:Obj		libraries()
	
	abstract Type[]			componentTypes(Str library)
	
	abstract EfanLibrary	library(Type componentType)
}	

internal const class EfanLibrariesImpl : EfanLibraries {
	
	private const Str:Pod 			libNameToPod
	private const Pod:Str 			podToLibName
	private const Str:EfanLibrary	librariesF

	@Inject	private	const Registry			registry
	@Inject	private	const ComponentFinder	componentFinder

	new make(Str:Pod libraries, LibraryCompiler libraryCompiler, Registry registry, |This|in) {
		in(this)

		this.libNameToPod	= verifyLibNames(libraries)

		p2l		:= Utils.makeMap(Pod#, Str#)
		libraries.each |pod, libName| { p2l[pod] = libName }
		this.podToLibName = p2l.toImmutable
		
		this.librariesF = libraries.map |pod, libName| { 
			type 	:= libraryCompiler.compileLibrary(libName, pod)
			lib		:= registry.autobuild(type)
			return lib
		}.toImmutable
	}

	override Str:Obj libraries() { librariesF }
	
	override Type[] componentTypes(Str library) {
		componentFinder.findComponentTypes(libNameToPod[library])
	}
	
	override EfanLibrary library(Type componentType) {
		// TODO: err if not found
		libName := podToLibName[componentType.pod]
		return librariesF[libName]
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
