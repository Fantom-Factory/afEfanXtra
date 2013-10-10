using afIoc::Inject

internal const class EfanExtraPrinter {
	private const static Log log := Utils.getLog(EfanExtraPrinter#)

	@Inject private	const EfanExtra 		efanExtra
	@Inject private	const LibraryCompiler	libraryCompiler
	
	new make(|This| in) { in(this) }

	Void libraryDetailsToStr() {
		buf := StrBuf().add("\n")

		efanExtra.libraries.each |library| {
			comTypes := efanExtra.componentTypes(library)
			
			maxName	 := (Int) comTypes.reduce(0) |size, component| { ((Int) size).max(component.name.toDisplayName.size) }
			buf.add("\nEfan Library: '${library}' has ${comTypes.size} components:\n")

			comTypes.each |component| {
				line := component.name.toDisplayName.padl(maxName) + " : " + "${library}." + libraryCompiler.initMethodSig(component)
				buf.add("  ${line}\n")
			}
		}

		buf.add("\n")
		log.info(buf.toStr)		
	}
}
