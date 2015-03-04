using afBeanUtils::ArgNotFoundErr
using afConcurrent::SynchronizedMap
using afIoc::ActorPools
using afIoc::Inject
using afIoc::Registry
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
	abstract EfanLibrary findFor(Type componentType)

	** Returns the names of all the libraries.
	abstract Str[] names()

	** Returns the pod corresponding to the given lib name
	abstract Pod pod(Str name)

}	

internal const class EfanLibrariesImpl : EfanLibraries {
	@Inject	private	const Registry				registry
	@Inject	private	const ComponentFinder		componentFinder
	@Inject	private	const EfanLibraryCompiler	libraryCompiler
			private const Str:Pod 				pods
			private const SynchronizedMap		libsByName

	new make(Str:Pod libraries, ActorPools actorPools, |This|in) {
		in(this)
		pods 		= libraries		
		libsByName	= SynchronizedMap(actorPools["afEfanXtra.caches"]) { it.keyType = Pod#; it.valType = EfanLibrary# }
	}
	
	override Pod pod(Str libraryName) {
		pods[libraryName] ?: throw ArgNotFoundErr(ErrMsgs.libraryNameNotFound(libraryName), pods.keys)
	}

	override EfanLibrary get(Str libraryName) {
		getByPod(pod(libraryName))
	}

	override EfanLibrary[] all() {
		pods.vals.map { getByPod(it) }
	}

	override EfanLibrary findFor(Type componentType) {
		getByPod(componentType.pod)
	}
	
	override Str[] names() {
		pods.keys
	}

	private EfanLibrary getByPod(Pod pod) {
		libsByName.getOrAdd(pod) |key->EfanLibrary| {
			name := pods.eachWhile |p, name->Str?| { p == pod ? name : null } ?: throw ArgNotFoundErr(ErrMsgs.libraryPodNotFound(pod), pods.vals)
			type := libraryCompiler.compileLibrary(name, pod)
			return registry.autobuild(type)
		}
	}	
	internal static Str[] verifyLibNames(Str:Pod libraries) {
		libraries.keys.each |libName| { if (!isFieldName(libName)) throw EfanErr(ErrMsgs.libraryNameNotValid(libName)) }
		return libraries.keys
	}

	** @see http://fantom.org/sidewalk/topic/2193#c14128
	private static Bool isFieldName(Str s) {
		!s.isEmpty && (s[0].isAlpha || s[0] == '_') && s.all |c| { c.isAlphaNum || c == '_' }
	}	
}

