
@NoDoc
const class ComponentMeta {

	Method? findMethod(Type comType, Type facetType) {
		methods := comType.methods.findAll { it.hasFacet(facetType) }

		if (methods.size > 1)
			throw Err("I only need the one, Fool!")	// FIXME: better Err msg

		if (methods.size == 1)
			return methods.first

		// last ditch attempt - look for a method with the same name as the facet
		return comType.method(facetType.name.decapitalize, false)
	}

	Obj? callMethod(Type comType, Type facetType, Obj instance, Obj[] args) {
		method := findMethod(comType, facetType)
		
		if (method == null)
			return null
		
		at:=args.map { it.typeof }
		if (!ReflectUtils.paramTypesFitMethodSignature(at, method))
		// FIXME: better Err msg
			throw Err("It don't fit, Fool!")
		
		return method.callOn(instance, args)
	}
	
	
	Str methodSig(Type comType, Type facetType, Str extraParams := Str.defVal) {
		initSig := findMethod(comType, facetType)?.params?.map { "${it.type.signature} ${it.name}" } ?: Str[,]
		if (!extraParams.isEmpty)
			initSig.add(extraParams)
		return initSig.join(", ").replace("sys::", "") 
	}

	Str methodDec(Type comType, Type facetType) {
		"render${comType.name.capitalize}(${methodSig(comType, facetType)})"
	}
}
