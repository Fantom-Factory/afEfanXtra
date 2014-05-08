using afIoc::Inject
using afIoc::NotFoundErr
using afIoc::Registry
using afEfan::EfanErr

@NoDoc
const mixin EfanLibraries {

	** Returns the efan library with the given name. Throws 'ArgErr' if such a library does not exist.
	@Operator
	abstract EfanLibrary get(Str libraryName)

	** Returns all the efan libraries.
	abstract EfanLibrary[] all()

	** Returns the library that contains the given *component* type.
	abstract EfanLibrary find(Type componentType)

}	

internal const class EfanLibrariesImpl : EfanLibraries {
	
	@Inject	private	const Registry			registry
	@Inject	private	const ComponentFinder	componentFinder
			private const Str:EfanLibrary	librariesByName
			private const Type:EfanLibrary	librariesByComType

	new make(Str:Pod libraries, EfanLibraryCompiler libraryCompiler, Registry registry, |This|in) {
		in(this)

		libs := Str:EfanLibrary[:]
		verifyLibNames(libraries).sort.each |name| {
			type := libraryCompiler.compileLibrary(name, libraries[name])
			libs[name] = registry.autobuild(type)
		}
		this.librariesByName = libs

		types := Type:EfanLibrary[:]
		librariesByName.each |lib| {
			lib.componentTypes.each { types[it] = lib }
		}
		this.librariesByComType = types
	}
	
	override EfanLibrary get(Str libraryName) {
		librariesByName[libraryName] // FIXME: null
	}

	override EfanLibrary[] all() {
		librariesByName.vals
	}

	override EfanLibrary find(Type componentType) {
		librariesByComType[componentType] ?: throw NotFoundErr(ErrMsgs.libraryNotFound(componentType), librariesByComType.keys)
	}
	
//	override Str:EfanLibrary libraries() { librariesF }
//
//	override Type[] componentTypes(Str library) {
//		componentFinder.findComponentTypes(libNameToPod[library])
//	}
//
//	override EfanLibrary library(Type componentType) {
//		libName := podToLibName[componentType.pod]
//		if (libName == null)
//			throw NotFoundErr(ErrMsgs.libraryNotFound(componentType.pod), podToLibName.keys)
//		return librariesF[libName]
//	}

	internal static Str[] verifyLibNames(Str:Pod libraries) {
		libraries.keys.each |libName| { if (!isFieldName(libName)) throw EfanErr(ErrMsgs.libraryNameNotValid(libName)) }
		return libraries.keys
	}

	** @see http://fantom.org/sidewalk/topic/2193#c14128
	private static Bool isFieldName(Str s) {
		!s.isEmpty && (s[0].isAlpha || s[0] == '_') && s.all |c| { c.isAlphaNum || c == '_' }
	}	
}
