
internal const class ErrMsgs {

	static Str componentTemplateNotFound(Type componentType) {
		"Could not find template file for ${componentType.qname}"
	}
	
	static Str templateConverterNotFound(File file) {
		"Could not find an efan converter for file extension '${file.ext}': ${file.normalize}"
	}

	static Str componentNotMixin(Type type) {
		"EfanExtra component ${type.qname} is NOT a mixin"
	}

	static Str componentNotConst(Type type) {
		"EfanExtra component ${type.qname} is NOT const"
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

	static Str templateDirNotFound(File templateDir) {
		"Template Dir `${templateDir.normalize}` does not exist!"
	}
	
}
