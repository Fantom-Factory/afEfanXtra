using afIoc::Inject
using afIoc::Registry
using afIoc::NotFoundErr


// TODO: maybe rename to EfanExtra
// TODO: have helper methods to iterate over pods and components
const mixin EfanLibraries {

	abstract Str:Obj 	libraries()
	
	abstract Type[] getComponentTypes(Str prefix)
	
	abstract Type[] libraryTypes()
	
}

internal const class EfanLibrariesImpl : EfanLibraries {
	private const static Log log := Utils.getLog(EfanLibraries#)
	
	private const Str:Pod 	prefixToPod
	private const Pod:Obj 	podToLibrary
	private const Str:Obj 	librariesF
		override Str:Obj 	libraries() { librariesF }
	
	@Inject	private	const Registry			registry

	new make(Str:Pod libraries, ComponentsProvider componentsProvider, LibraryCompiler libraryCompiler, Registry registry, |This|in) {
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
		
		componentsProvider.libs.val = librariesF.vals.toImmutable		
	}
	
	** TODO: Fudge for now / PagePipeline in afPillow
	override Type[] getComponentTypes(Str prefix) {
		findComponentTypes(prefixToPod[prefix])
	}
	
	@NoDoc
	override Type[] libraryTypes() {
		podToLibrary.vals.map { it.typeof }
	}
	
	
	
	// TODO: this is also in LibraryCompiler
	private Type[] findComponentTypes(Pod pod) {
		pod.types.findAll { it.fits(Component#) && it.isMixin && it != Component# }		
	}

}
