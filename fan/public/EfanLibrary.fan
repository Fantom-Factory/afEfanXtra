using afIoc::Inject

@NoDoc
const mixin EfanLibrary {

	Str render(Type componentType, Obj[] initParams) {

		methodName	:= "render${componentType.name.capitalize}"
		method		:= typeof.method(methodName)
		
		paramTypes	:= initParams.map { it.typeof }
		if (!ReflectUtils.paramTypesFitMethodSignature(paramTypes, method))
			throw Err("404 baby!")	// TODO: Err msg
		
		return method.callOn(this, initParams)
	}
	
}
