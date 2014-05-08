
internal const class ErrMsgs {

	static Str componentTemplateNotFound(Type componentType) {
		"Could not find template file for ${componentType.qname}"
	}
	
	static Str templateConverterNotFound(File file) {
		"Could not find an efan converter for file extension '${file.ext}': ${file.normalize}"
	}

	static Str componentNotMixin(Type type) {
		"EfanXtra component ${type.qname} is NOT a mixin"
	}

	static Str componentNotConst(Type type) {
		"EfanXtra component ${type.qname} is NOT const"
	}

	static Str libraryNameNotValid(Str libName) {
		"Efan Library name is not valid. It must be a legal Fantom name : ${libName}"
	}

	static Str templateNotFile(Uri templateLoc, Type comType, Type templateType) {
		"Template Uri `${templateLoc}` for ${comType.qname} does not resolve to a file : ${templateType.qname}"
	}

	static Str templateNotFound(Uri templateLoc, Type comType) {
		"Template Uri `${templateLoc}` for ${comType.qname} could not be resolved!"
	}

	static Str templateDirIsNotDir(File templateDir) {
		"Template Dir `${templateDir.normalize}` is not a directory!"
	}

	static Str libraryNotFound(Type type) {
		"Could not find efan library for component type '${type.qname}'"
	}

	static Str componentMetaTooManyMethods(Type comType, Type facetType) {
		"${comType.qname} should only have ONE method annotated with @${facetType.name}"
	}

	static Str componentMetaParamsDontFitMethod(Type[] types, Method method) {
		stripSys("Param types [" + types.map { it.qname } + "] does not fit method signature: ${method.signature}")
	}

	static Str componentCompilerWrongReturnType(Method method, Type[] allowedReturnTypes) {
		stripSys("Method '${method.returns.name} ${method.qname}' should return one of " + allowedReturnTypes.join(", ") { it.name })
	}

	static Str alienAidComponentTypo(Str libName, Str comName) {
		"\n  ALIEN-AID: Did you mean: ${libName}.render${comName}(...) ???"
	}

	static Str metaTypesDoNotFitMethod(Type? facetType, Method initMethod, Type?[] types) {
		t := types.join(", ") { it?.signature ?: "" }
		f := facetType != null ? "@${facetType.name} " : ""
		return stripSys("${f}${initMethod.parent.qname} ${initMethod.signature} can not be called with param types [${t}]")
	}
	
	private static Str stripSys(Str str) {
		str.replace("sys::", "")
	}
}
