using afBeanUtils::ArgNotFoundErr
using afBeanUtils::ReflectUtils
using afEfan::EfanErr

@NoDoc
const class ComponentMeta {

	Method? findMethod(Type comType, Type facetType) {
		methods := comType.methods.findAll { it.hasFacet(facetType) }

		if (methods.size > 1)
			throw ArgNotFoundErr(componentMetaTooManyMethods(comType, facetType), methods.map { it.name })

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
		if (!ReflectUtils.argTypesFitMethod(types, method))
			throw EfanErr(metaTypesDoNotFitMethod(facetType, method, types))

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
	
	private static Str componentMetaTooManyMethods(Type comType, Type facetType) {
		"${comType.qname} should only have ONE method annotated with @${facetType.name}"
	}

	private static Str metaTypesDoNotFitMethod(Type? facetType, Method initMethod, Type?[] types) {
		t := types.join(", ") { it?.signature ?: "" }
		f := facetType != null ? "@${facetType.name} " : ""
		return stripSys("${f}${initMethod.parent.qname} ${initMethod.signature} can not be called with param types [${t}]")
	}
	
	private static Str stripSys(Str str) {
		str.replace("sys::", "")
	}

//	static Str componentMetaParamsDontFitMethod(Type[] types, Method method) {
//		stripSys("Param types [" + types.map { it.qname } + "] does not fit method signature: ${method.signature}")
//	}

}
