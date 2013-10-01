using afIoc::Inject
using afIoc::Registry
using afIoc::NotFoundErr
using afPlastic::PlasticCompiler
using afPlastic::PlasticClassModel
using afEfan::EfanRenderer
using afEfan::EfanRenderCtx

const mixin EfanLibraries {

	abstract Str:Obj 	libraries()
	
	abstract Type[] getComponentTypes(Str prefix)
	
	abstract Type[] libraryTypes()
	
//	abstract Obj library(Type libraryType)
}

const class EfanLibrariesImpl : EfanLibraries {
	private const static Log log := Utils.getLog(EfanLibraries#)
	
	private const Str:Pod 	prefixToPod
	private const Pod:Obj 	podToLibrary
	private const Str:Obj 	librariesF
		override Str:Obj 	libraries() { librariesF }
	
	@Inject	private	const Registry			registry
	@Inject	private	const PlasticCompiler	plasticCompiler
	
	new make(Str:Pod libraries, ComponentsProvider componentsProvider, |This|in) {
		in(this)

		libs := Utils.makeMap(Str#, Obj#)
		this.prefixToPod	= libraries
		this.podToLibrary 	= libraries.map |pod, prefix| { 
			type 	:= compileLibrary(prefix, pod)
			lib		:= registry.autobuild(type)
			libs[prefix] = lib
			return lib
		}
		this.librariesF = libs.toImmutable
		
		componentsProvider.libs.val = librariesF.vals.toImmutable
//		componentsProvider.types.val = librariesF.vals.map { it.typeof }
	}
	
	** Fudge for now
	override Type[] getComponentTypes(Str prefix) {
		findComponentTypes(prefixToPod[prefix])
	}
	
	@NoDoc
	override Type[] libraryTypes() {
		podToLibrary.vals.map { it.typeof }
	}
	
//	@NoDoc
//	override Obj library(Type libraryType) {
//		podToLibrary.find { it.typeof.fits(libraryType) }
//	}


	
	private Type compileLibrary(Str prefix, Pod pod) {
		// TODO: log stuff
		model := PlasticClassModel("${prefix.capitalize}EfanLibrary", true)
		
		model.usingType(EfanRenderer#)
		model.usingType(EfanRenderCtx#)
		model.addField(ComponentCache#, "componentCache", null, null, [Inject#])
		
		findComponentTypes(pod).each |com| {			
			method	:= com.methods.find { it.name == "initialise" }
			
			initSig := (method?.params?.map { "${it.type.signature} ${it.name}" } ?: Str[,]).add("|EfanRenderer obj| bodyFunc")
			
			body := "component := (${com.qname}) componentCache.createInstance(${com.qname}#)\n"
			
			// TODO: make more robust
			if (com.method("initialise", false) != null)
				body += "component.initialise(" + (method?.params?.join(", ") { it.name } ?: "") + ")\n"
			body += "EfanRenderCtx.render.efan(component, null, bodyFunc)\n"
			body += "return component"
			
			model.addMethod(com, "render" + com.name.capitalize, initSig.join(", "), body)
		}
		
//		Env.cur.err.printLine(model.toFantomCode)
		return plasticCompiler.compileModel(model)
	}
	
// the rendered method
//	Layout renderLayout(Str pageTitle, |EfanRenderer obj| bodyFunc) {
//		component := (Layout) efanLibraries.create(Layout#)
//		component.initialise(pageTitle)
//		EfanRenderCtx.render.efan(component, null, bodyFunc)
//		return component
//	}		
	
	
	private Type[] findComponentTypes(Pod pod) {
		pod.types.findAll { it.fits(Component#) && it.isMixin && it != Component# }		
	}

	static Void main(Str[] args) {
		Obj#.field("toStr", false)
	}
}
