using afIoc::Inject

const mixin EfanLibrary {
	
	@Inject	abstract ComponentCache componentCache
	
	// sigh - it's just easier to make one than to publicly inject one!
	private ComponentMeta	componentMeta() { ComponentMeta() }
	
	Str render(Type componentType, Obj[] initParams) {

		component	:= componentCache.getOrMake(componentType)
		initMethod	:= componentMeta.initMethod(componentType)
		
		return component->_af_componentHelper->scopeVariables() |->Obj?| {
			if (initMethod != null) {
				paramTypes	:= initParams.map { it.typeof }
				if (!ReflectUtils.paramTypesFitMethodSignature(paramTypes, initMethod))
					throw Err("404 baby!")	// TODO: Err msg
				
				initMethod.callOn(component, initParams)
			}
		
			return component.render(null)
		}
	}
	
}
