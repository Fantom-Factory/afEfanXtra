using afBeanUtils::ArgNotFoundErr
using afConcurrent::SynchronizedMap
using afConcurrent::ActorPools
using afIoc::Inject
using afIoc::Scope
using afEfan::EfanErr

** (Service) - Contribute your library pods to this. 
@NoDoc
const mixin EfanLibraries {

	** Returns the efan library with the given name. Throws 'ArgErr' if such a library does not exist.
	@Operator
	abstract EfanLibrary get(Str libraryName)

	** Returns all the efan libraries.
	abstract EfanLibrary[] all()

	** Returns the library that contains the given *component* type.
	** 
	** If the same pod has been contributed more than once, under different names, 
	** the actual 'EfanLibrary' returned is indeterminate. 
	abstract EfanLibrary findFor(Type componentType)

	** Returns the names of all the libraries.
	abstract Str[] names()

	** Returns the pod corresponding to the given lib name
	abstract Pod pod(Str name)

}	

internal const class EfanLibrariesImpl : EfanLibraries {
	@Inject	private	const Scope					scope
	@Inject	private	const ComponentFinder		componentFinder
	@Inject	private	const EfanLibraryCompiler	libraryCompiler
			private const Str:Pod 				pods
			private const SynchronizedMap		libsByName

	new make(Str:Pod libraries, ActorPools actorPools, |This|in) {
		in(this)
		pods 		= libraries		
		libsByName	= SynchronizedMap(actorPools["afEfanXtra.caches"]) { it.keyType = Str#; it.valType = EfanLibrary# }
	}
	
	override Pod pod(Str libraryName) {
		pods[libraryName] ?: throw ArgNotFoundErr("Could not find efan library with name '${libraryName}'", pods.keys)
	}

	override EfanLibrary get(Str libraryName) {
		getByName(libraryName)
	}

	override EfanLibrary[] all() {
		pods.keys.map |name -> EfanLibrary| { getByName(name) }
	}

	override EfanLibrary findFor(Type componentType) {
		libName := pods.keys.find { pods[it] == componentType.pod }
		return getByName(libName)
	}
	
	override Str[] names() {
		pods.keys
	}

	private EfanLibrary getByName(Str libName) {
		libsByName.getOrAdd(libName) |key->EfanLibrary| {
			type := libraryCompiler.compileLibrary(libName, pods[libName])
			return scope.build(type)
		}
	}
	
	internal static Str[] verifyLibNames(Str:Pod libraries) {
		libraries.keys.each |libName| { if (!isFieldName(libName)) throw EfanErr("Efan Library name is not valid. It must be a legal Fantom name : ${libName}") }
		return libraries.keys
	}

	** @see http://fantom.org/sidewalk/topic/2193#c14128
	private static Bool isFieldName(Str s) {
		!s.isEmpty && (s[0].isAlpha || s[0] == '_') && s.all |c| { c.isAlphaNum || c == '_' }
	}	
}

