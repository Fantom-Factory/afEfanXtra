using afIoc::Inject
using afIoc::Scope
using afConcurrent::AtomicList
using afConcurrent::AtomicMap
using afEfan::EfanMeta

@NoDoc	// Advanced use only
const class ObjCache {
	private const Type[] 		serviceTypeCache
	private const AtomicMap		constTypeCache		:= AtomicMap()
	private const AtomicList	autobuildTypeCache	:= AtomicList()
	
	@Inject	private const |->Scope|	activeScope

	new make(|This|in) {
		in(this) 
		this.serviceTypeCache = activeScope().registry.serviceDefs.vals.map { it.type }
	}

	@Operator
	Obj get(EfanMeta meta) {
		type := meta.type
		
		obj := null
		if (serviceTypeCache.contains(type))
			obj = activeScope().serviceByType(type)

		else
		if (constTypeCache.containsKey(type))
			obj = constTypeCache[type]
		
		else
		if (autobuildTypeCache.contains(type))
			obj = activeScope().build(type, [meta])
		
		if (obj == null) {
			if (type.isConst) {
				obj = activeScope().build(type, [meta])
				constTypeCache.set(type, obj)
				
			} else {
				autobuildTypeCache.add(type)
				obj = activeScope().build(type, [meta])
			}
		}

		return obj
	}
	
	Void remove(EfanMeta? meta) {
		if (meta == null) return
		type := meta.type
		
		if (constTypeCache.containsKey(type))
			constTypeCache.remove(type)
		else
		if (autobuildTypeCache.contains(type))
			autobuildTypeCache.remove(type)
	}
}
