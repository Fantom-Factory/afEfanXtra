using afPlastic::PlasticCompiler
using afEfan::EfanCompiler

** Exists so a (BedSheet) builder method may override the values with contributed ones.
** I should really improve the Config code and move it into its own module! 
@NoDoc
const class EfanExtraConfig {
	
	** When generating code snippets to report compilation Errs, this is the number of lines of src 
	** code the erroneous line will be padded with.  
	public const  Int 			srcCodePadding		:= 5 

	public const  Duration		templateTimeout		:= 10sec 

	internal EfanCompiler efanCompiler() {
		EfanCompiler() {
			it.srcCodePadding = this.srcCodePadding
		}
	}

	internal PlasticCompiler plasticCompiler() {
		PlasticCompiler() {
			it.srcCodePadding = this.srcCodePadding
		}
	}
}
