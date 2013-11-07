
// used by afBedSHeetEfanExtra for logging purposes
@NoDoc
const class ComponentMeta {
	
	Method? initMethod(Type componentType) {
		componentType.methods.find { it.name == "initialise" }
	}
	
	Str initMethodSig(Type componentType, Str extraParams := Str.defVal) {
		initSig := initMethod(componentType)?.params?.map { "${it.type.signature} ${it.name}" } ?: Str[,]
		if (!extraParams.isEmpty)
			initSig.add(extraParams)
		return initSig.join(", ").replace("sys::", "") 
	}

	Str renderMethodDec(Type componentType) {
		"render${componentType.name.capitalize}(${initMethodSig(componentType)})"
	}
}
