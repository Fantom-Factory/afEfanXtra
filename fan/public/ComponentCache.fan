using afIoc::ConcurrentCache
using afIoc::Inject
using afIoc::Registry
using afIoc::NotFoundErr
using afPlastic::PlasticClassModel

const mixin ComponentCache {

	** Called from compiled library methods
	abstract Component createInstance(Type componentType)

}

internal const class ComponentCacheImpl : ComponentCache {
	private const ConcurrentCache efanTypeCache	:= ConcurrentCache() 

	@Inject	private const TemplateConverters	templateConverters
	@Inject	private const ComponentCompiler		compiler
	@Inject	private const Registry 				registry

	new make(|This|in) { in(this) }
	
	override Component createInstance(Type componentType) {
		
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
