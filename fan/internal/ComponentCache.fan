using afIoc::ConcurrentCache
using afIoc::Inject
using afIoc::Registry
using afIoc::NotFoundErr
using afPlastic::PlasticClassModel
using afEfan::EfanRenderer
using afIocConfig::Config

** Lazy cache of efan components.
@NoDoc
const mixin ComponentCache {

	abstract EfanComponent getOrMake(Str libName, Type componentType)

}

internal const class ComponentCacheImpl : ComponentCache {

	@Config { id="afEfan.templateTimeout" }
	@Inject	private const Duration 				templateTimeout
	@Inject	private const EfanTemplateFinders	templateFinders
	@Inject	private const ComponentCompiler		compiler
			private const FileCache 			fileCache
			private const ConcurrentCache 		typeToState	:= ConcurrentCache() 

	new make(|This|in) { 
		in(this) 
		fileCache = FileCache(templateTimeout)
	}

	override EfanComponent getOrMake(Str libName, Type componentType) {
		
		state := (ComponentCacheState) typeToState.getOrAdd(componentType) |->ComponentCacheState| {
			templateFile 	:= templateFinders.findTemplate(componentType)
			componentInst	:= compiler.compile(libName, componentType, templateFile)
			
			state := ComponentCacheState() {
				it.componentType 	= componentType
				it.componentInst	= componentInst
				it.templateFile		= templateFile
			}
			
			fileCache.addFile(templateFile)
			
			return state
		}

		// re-compile component if the template's been updated 
		fileCache.updateFile(state.templateFile) |->| {
			newComponent	:= compiler.compile(libName, state.componentType, state.templateFile)
			typeToState[state.componentType] = state.withComponent(newComponent)
		}
		
		return state.componentInst
	}
}

internal const class ComponentCacheState {
	const Type			componentType
	const EfanComponent	componentInst
	const File 			templateFile
	
	new make(|This|in) { in(this) }
	
	ComponentCacheState withComponent(EfanComponent componentInst) {
		Utils.cloneObj(this) |Field:Obj plan| {
			plan[#componentInst] = componentInst
		}
	}
}

//internal const mixin Clonable {
//	This clone(|Field:Obj|? overridePlan := null) {
//		plan := Field:Obj[:]
//		typeof.fields.each {
//			value := it.get(this)
//			if (value != null)
//				plan[it] = value
//		}
//		
//		overridePlan.call(plan)
//		
//		planFunc := Field.makeSetFunc(plan)
//		return (Clonable) typeof.make([planFunc])
//	}
//}
