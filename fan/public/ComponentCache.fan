using afIoc::ConcurrentCache
using afIoc::Inject
using afIoc::Registry
using afIoc::NotFoundErr
using afPlastic::PlasticClassModel

const class ComponentCache {
	private const ConcurrentCache efanTypeCache	:= ConcurrentCache() 

	@Inject	private const ComponentCompiler		compiler
	@Inject	private const Registry 				registry

	
	new make(|This|in) { in(this) }
	
	** Called from compiled library methods
	@NoDoc
	Component createInstance(Type componentType) {
		
		if (!efanTypeCache.containsKey(componentType)) {
			templateFile	:= findTemplate(componentType) 
			compiledType	:= compiler.compile(componentType, templateFile)
			efanTypeCache[componentType] = compiledType
		}
		
		type 	:= efanTypeCache[componentType]
		com		:= registry.autobuild(type)
		return com		
	}
	
	private File findTemplate(Type componentType) {
		// TODO: have some contribution of extenstions 
		templateFiles := componentType.pod.files.findAll { it.ext == "efan" || it.ext == "slim" }
		return templateFiles.find |file->Bool| {
			index 		:= file.name.index(".")
			fileName	:= file.name[0..<index].lower
			pageName	:= componentType.name.lower
			if (fileName == pageName)
				return true
			if (pageName.endsWith("page") && fileName == pageName[0..<-4])
				return true
			return false
		} ?: throw NotFoundErr(ErrMsgs.componentTemplateNotFound(componentType), templateFiles)
	}	
}
