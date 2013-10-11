
internal const class ComponentMeta {
	
	Method? initMethod(Type componentType) {
		componentType.methods.find { it.name == "initialise" }
	}
	
	Str initMethodSig(Type componentType, Str extraParams := "") {
		initSig := (initMethod(componentType)?.params?.map { "${it.type.signature} ${it.name}" } ?: Str[,]).add(extraParams)
		return initSig.join(", ").replace("sys::", "") 
	}

	Str renderMethodDec(Type componentType) {
		"render${componentType.name.capitalize}(${initMethodSig(componentType)})"
	}
}
