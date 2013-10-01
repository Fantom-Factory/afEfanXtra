
internal const class ErrMsgs {

	static Str componentTemplateNotFound(Type componentType) {
		"Could not find template file for ${componentType.qname}"
	}
	
	static Str templateConverterNotFound(File file) {
		"Could not find an efan converter for file extension '${file.ext}': ${file.normalize}"
	}
	
}
