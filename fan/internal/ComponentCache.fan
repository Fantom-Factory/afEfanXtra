using afConcurrent
using afIoc::Inject
using afIoc::Scope
using afEfan::EfanMeta

** Lazy cache of efan components.
@NoDoc
const mixin ComponentCache {

	abstract EfanComponent getOrMake(Type componentType)

}

internal const class ComponentCacheImpl : ComponentCache {

	@Inject	private const TemplateFinders		templateFinders
	@Inject	private const ComponentCompiler		compiler
	@Inject	private const ObjCache				objCache
			private const SynchronizedMap		metaCache

	new make(ActorPools actorPools, |This|in) { 
		in(this) 
		metaCache = SynchronizedMap(actorPools["afEfanXtra.caches"]) { it.keyType = Type#; it.valType = EfanMeta# }
	}

	override EfanComponent getOrMake(Type comType) {
		templateSrc := templateFinders.getOrFindTemplate(comType)
		efanMeta	:= (EfanMeta?) metaCache.get(comType)

		if (efanMeta == null || templateSrc.isModified) {
			oldMeta := efanMeta
			efanMeta = metaCache.lock.synchronized |->Obj?| {
				templateSrc.checked				// update the last checked timestamp
				if (oldMeta != null && templateSrc.isModified == false)
					return oldMeta
				
				newMeta := compiler.compile(comType, templateSrc)
				metaCache[comType] = newMeta

				// todo should we delete the old const instance?
				// we would need to remove it here, but we should be adding the new one first so we don't ever return null
				// but can't build it here, 'cos we're in the wrong active scope / thread
				// and we can't build it elsewhere due to race conditions 
				return newMeta
			}
		}

		return objCache.get(efanMeta)
	}
}
