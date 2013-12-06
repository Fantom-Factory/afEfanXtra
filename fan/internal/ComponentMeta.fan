using afIoc::NotFoundErr
using afEfan::EfanErr

@NoDoc
const class ComponentMeta {

	Method? findMethod(Type comType, Type facetType) {
		methods := comType.methods.findAll { it.hasFacet(facetType) }

		if (methods.size > 1)
			throw NotFoundErr(ErrMsgs.componentMetaTooManyMethods(comType, facetType), methods.map { it.name })

		if (methods.size == 1)
			return methods.first

		// last ditch attempt - look for a method with the same name as the facet
		return comType.method(facetType.name.decapitalize, false)
	}

	Obj? callMethod(Type comType, Type facetType, Obj instance, Obj[] args) {
		method := findMethod(comType, facetType)
		
		if (method == null)
			return null
		
		// FIXME: fantom topic - types := args.map |arg->Type| { arg.typeof }  types is Obj?[], not Type[]
		types := (Type[]) args.map { it.typeof }
		if (!ReflectUtils.paramTypesFitMethodSignature(types, method))
			throw EfanErr()
		
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
