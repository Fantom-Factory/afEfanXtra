using afIoc::Inject
using afIoc::Registry
using afIoc::NotFoundErr

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
		libraries
	}
}
