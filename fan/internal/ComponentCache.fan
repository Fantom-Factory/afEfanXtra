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
				// double check and double lock 
				if (oldMeta != null && templateSrc.isModified == false)
					return oldMeta
				
				newMeta := compiler.compile(comType, templateSrc)
				metaCache[comType] = newMeta

				// there's a small race condition here, whereby the Obj could be asked for and added back to Obj cache
				// but given this is only dev envs, it's hardly gonna cause a memory leak
				objCache.remove(oldMeta)

				return newMeta
			}
		}

		return objCache.get(efanMeta)
	}
}
