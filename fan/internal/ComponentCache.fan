using afIoc::ConcurrentCache
using afIoc::Inject
using afIoc::Registry
using afIoc::NotFoundErr
using afPlastic::PlasticClassModel

@NoDoc
const mixin ComponentCache {

	abstract Component createInstance(Type componentType)

}

internal const class ComponentCacheImpl : ComponentCache {
//	private const ConcurrentCache efanTypeCache	:= ConcurrentCache() 
	private const ConcurrentCache typeToFileCache	:= ConcurrentCache() 

			private const FileCache 			fileCache
	@Inject	private const TemplateConverters	templateConverters
	@Inject	private const ComponentCompiler		compiler
	@Inject	private const Registry 				registry

	new make(EfanExtraConfig config, |This|in) { 
		in(this) 
		fileCache = FileCache(config.templateTimeout)
	}
	
	override Component createInstance(Type componentType) {
		templateFile := (File) typeToFileCache.getOrAdd(componentType) |->File| {
			findTemplate(componentType) 
		}
		
		efanType := (Type) fileCache.getOrAddOrUpdate(templateFile) |->Obj| {
			compiler.compile(componentType, templateFile)
		}
		
		component := registry.autobuild(efanType)
		return component
	}
	
	private File findTemplate(Type componentType) {
		templateFiles := componentType.pod.files.findAll { templateConverters.extensions.contains(it.ext.lower) }
		return templateFiles.find |file->Bool| {
			index 		:= file.name.index(".")
			fileName	:= file.name[0..<index].lower
			pageName	:= componentType.name.lower
			if (fileName == pageName)
				return true
			
			// TODO: Maybe have a TemplateSuffixes service
			if (pageName.endsWith("page") && fileName == pageName[0..<-4])
				return true
			
			return false
		} ?: throw NotFoundErr(ErrMsgs.componentTemplateNotFound(componentType), templateFiles)
	}	
}
