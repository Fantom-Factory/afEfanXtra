using afIoc::Inject
using afIocConfig::Config

** Used by afPillow
@NoDoc
const class EfanXtraPrinter {
	private const static Log log := Utils.getLog(EfanXtraPrinter#)

	@Inject private	const EfanLibraries		efanLibraries
	@Inject private	const ComponentMeta		componentMeta
	
	@Config { id="afEfan.supressStartupLogging" }
	@Inject private const Bool				supressStartupLogging
	
	new make(|This| in) { in(this) }

	Void logLibraries() {
		if (supressStartupLogging)
			return

		details := "\n"
		efanLibraries.all.each |lib| {
			details += libraryDetailsToStr(lib) { true }
		}

		log.info(details)		
	}

	Str libraryDetailsToStr(EfanLibrary lib, |Type component->Bool| filter) {
		buf		 := StrBuf()
		comTypes := lib.componentTypes.findAll(filter)
		
		maxName	 := (Int) comTypes.reduce(0) |size, component| { ((Int) size).max(component.name.toDisplayName.size) }
		buf.add("\nefan Library: '${lib.name}' has ${comTypes.size} components:\n\n")

		comTypes.each |comType| {
			line := comType.name.toDisplayName.padl(maxName) + " : " + "${lib.name}." + componentMeta.methodDec(comType, InitRender#)
			buf.add("  ${line}\n")
		}
		
		return buf.toStr
	}
}
