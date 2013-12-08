using afIoc::Inject
using afIocConfig::Config

** Used by afBedSheetEfanExtra
@NoDoc
const class EfanXtraPrinter {
	private const static Log log := Utils.getLog(EfanXtraPrinter#)

	@Inject private	const EfanXtra 			efanXtra
	@Inject private	const ComponentMeta		componentMeta
	
	@Config { id="afEfan.supressStartupLogging" }
	@Inject private const Bool				supressStartupLogging
	
	new make(|This| in) { in(this) }

	Void logLibraries() {
		if (supressStartupLogging)
			return

		details := "\n"
		efanXtra.libraries.each |libName| {
			details += libraryDetailsToStr(libName) { true }
		}

		log.info(details)		
	}

	Str libraryDetailsToStr(Str libName, |Type component->Bool| filter) {
		buf		 := StrBuf()
		comTypes := efanXtra.componentTypes(libName).findAll(filter)
		
		maxName	 := (Int) comTypes.reduce(0) |size, component| { ((Int) size).max(component.name.toDisplayName.size) }
		buf.add("\nEfan Library: '${libName}' has ${comTypes.size} components:\n")

		comTypes.each |comType| {
			line := comType.name.toDisplayName.padl(maxName) + " : " + "${libName}." + componentMeta.methodDec(comType, InitRender#)
			buf.add("  ${line}\n")
		}
		
		return buf.toStr
	}
}
