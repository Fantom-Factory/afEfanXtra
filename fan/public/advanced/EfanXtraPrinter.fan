using afIoc::Inject

** Used by afPillow
@NoDoc
const class EfanXtraPrinter {
	private const static Log log := Utils.getLog(EfanXtraPrinter#)

	@Inject private	const EfanLibraries		efanLibs
	@Inject private	const ComponentFinder	comFinder
	@Inject private	const ComponentMeta		comMeta
	
	new make(|This| in) { in(this) }

	Void logLibraries() {
		details := "\n"
		efanLibs.names.each |libName| {
			details += libraryDetailsToStr(libName) { true }
		}

		log.info(details)
	}

	Str libraryDetailsToStr(Str libName, |Type component->Bool| filter) {
		libPod := efanLibs.pod(libName)
		buf		 := StrBuf()
		comTypes := comFinder.findComponentTypes(libPod).findAll(filter)
		
		maxName	 := (Int) comTypes.reduce(0) |size, component| { ((Int) size).max(component.name.toDisplayName.size) }
		buf.add("\nefan Library: '${libName}' has ${comTypes.size} components:\n\n")

		comTypes.each |comType| {
			line := comType.name.toDisplayName.padl(maxName) + " : " + "${libName}." + comMeta.methodDec(comType, InitRender#)
			buf.add("  ${line}\n")
		}
		
		return buf.toStr
	}
}
