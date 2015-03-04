using fandoc::HtmlDocWriter
using fandoc::DocElem
using fandoc::Doc
using fandoc::FandocParser

** A basic Fandoc to HTML converter, so '.fandoc' files may be used as efan templates. If you don't wish .fandoc to be 
** converted into HTML (or want more conversion control), override the contribution:
** 
**   @Contribute { serviceType=TemplateConverters# }
**   internal static Void contributeTemplateConverters(MappedConfig config, MyConverter myConverter) {
**     config.setOverride("fandoc", "myfandoc") |File file -> Str| { myConverter.convert(file) }
**   }
@NoDoc
const mixin FandocToHtmlConverter {
	abstract Str convert(File fandocFile)
}

internal const class FandocToHtmlConverterImpl : FandocToHtmlConverter {
	
	override Str convert(File fandocFile) {
		fandoc	:= FandocParser().parseStr(fandocFile.readAllStr)
		efan	:= printDoc(fandoc.children).replace("&lt;%", "<%")
		return efan
	}

	private Str printDoc(DocElem[] doc) {
		buf	:= StrBuf()
		dw	:= PlainHtmlWriter(buf.out)
		doc.each { it.write(dw) }
		return buf.toStr			
	}
	
}

internal class PlainHtmlWriter : HtmlDocWriter {
	new make(OutStream out := Env.cur.out) : super(out) { }
	override Void docStart(Doc doc) { } 
	override Void docEnd(Doc doc) { }
}
