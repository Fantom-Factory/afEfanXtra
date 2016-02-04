using fandoc::HtmlDocWriter
using fandoc::DocElem
using fandoc::Doc
using fandoc::FandocParser

** A basic Fandoc to HTML converter, so '.fandoc' files may be used as efan templates. If you don't wish .fandoc to be 
** converted into HTML (or want more conversion control), override the contribution:
** 
**   syntax: fantom
** 
**   @Contribute { serviceType=TemplateConverters# }
**   internal static Void contributeTemplateConverters(MappedConfig config, MyConverter myConverter) {
**       config.setOverride("fandoc", "myfandoc") |Str src -> Str| { myConverter.convert(src) }
**   }
@NoDoc
const mixin FandocToHtmlConverter {
	abstract Str convert(Str fandocStr)
}

internal const class FandocToHtmlConverterImpl : FandocToHtmlConverter {
	
	override Str convert(Str fandocStr) {
		fandoc	:= FandocParser().parseStr(fandocStr)
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
