using afEfan::EfanErr

@NoDoc
const class ComponentMeta {

	Method? findMethod(Type comType, Type facetType) {
		methods := comType.methods.findAll { it.hasFacet(facetType) }

		if (methods.size > 1)
			throw ArgNotFoundErr(ErrMsgs.componentMetaTooManyMethods(comType, facetType), methods.map { it.name })

		if (methods.size == 1)
			return methods.first

		// last ditch attempt - look for a method with the same name as the facet
		return comType.method(facetType.name.decapitalize, false)
	}

	Obj? callMethod(Type facetType, Obj instance, Obj?[] args) {
		// look for the method on the instance, not just the mixin type, because the method may have been 
		// dynamically added to the model. 
		method := findMethod(instance.typeof, facetType)
		
		if (method == null)
			return null
		
		// Wot no type inference from List.map? - see http://fantom.org/sidewalk/topic/2217
		types := (Type?[]) args.map { it?.typeof }
		if (!ReflectUtils.paramTypesFitMethodSignature(types, method))
			throw EfanErr(ErrMsgs.metaTypesDoNotFitMethod(facetType, method, types))

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
