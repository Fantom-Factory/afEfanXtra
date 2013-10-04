using afIoc::Inject
using afIoc::Registry
using afIoc::NotFoundErr

@NoDoc
const mixin EfanLibraries {

	abstract Str:Obj	libraries()
	
	abstract Type[]		componentTypes(Str prefix)
	
	abstract Type[]		libraryTypes()
}

internal const class EfanLibrariesImpl : EfanLibraries {
	
	private const Str:Pod 	prefixToPod
	private const Pod:Obj 	podToLibrary
	private const Str:Obj 	librariesF
		override Str:Obj 	libraries() { librariesF }
	
	@Inject	private	const Registry			registry
	@Inject	private	const ComponentFinder	componentFinder

	new make(Str:Pod libraries, LibraryCompiler libraryCompiler, Registry registry, |This|in) {
		in(this)

		libs := Utils.makeMap(Str#, Obj#)
		this.prefixToPod	= libraries
		this.podToLibrary 	= libraries.map |pod, prefix| { 
			type 	:= libraryCompiler.compileLibrary(prefix, pod)
			lib		:= registry.autobuild(type)
			libs[prefix] = lib
			return lib
		}
		this.librariesF = libs.toImmutable
	}
	
	** TODO: Fudge for now / PagePipeline in afPillow
	override Type[] componentTypes(Str prefix) {
		componentFinder.findComponentTypes(prefixToPod[prefix])
	}
	
	@NoDoc
	override Type[] libraryTypes() {
		podToLibrary.vals.map { it.typeof }
	}
}
