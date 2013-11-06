using afIoc::ConcurrentCache
using afIoc::Inject
using afIoc::Registry
using afIoc::NotFoundErr
using afPlastic::PlasticClassModel
using afEfan::EfanRenderer
using afIocConfig::Config

@NoDoc
const mixin ComponentCache {

	abstract EfanRenderer getOrMake(Str libName, Type componentType)

}

internal const class ComponentCacheImpl : ComponentCache {
	private const ConcurrentCache typeToFileCache	:= ConcurrentCache() 

	@Inject @Config { id="afEfan.templateTimeout" }
	private const Duration templateTimeout

			private const FileCache 			fileCache
	@Inject	private const EfanTemplateFinders	templateFinders
	@Inject	private const ComponentCompiler		compiler

	new make(|This|in) { 
		in(this) 
		fileCache = FileCache(templateTimeout)
	}

	override EfanRenderer getOrMake(Str libName, Type componentType) {
		templateFile := (File) typeToFileCache.getOrAdd(componentType) |->File| {
			templateFinders.findTemplate(componentType) 
		}
		
		component := (EfanRenderer) fileCache.getOrAddOrUpdate(templateFile) |->Obj| {
			compiler.compile(libName, componentType, templateFile)
		}

		return component
	}
}
