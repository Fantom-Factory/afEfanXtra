using afEfan::EfanCompilationErr
using afEfan::EfanRuntimeErr
using afEfan::EfanMeta

** Static methods for rendering efan templates.
** All data is saved onto the ThreadLocal rendering stack.
@NoDoc
const class EfanRenderer {
	
	static Str renderComponent(EfanComponent component, |->|? bodyFunc, |Obj?| func) {
		renderBuf := StrBuf(component.efanMeta.templateSrc.size)
		EfanRenderingStack.withCtx(component.componentId) |EfanRenderingStackElement element| {
			element.ctx["efan.renderCtx"] = EfanRendererCtx(component, renderBuf, bodyFunc)
			convertErrs(component.efanMeta, func)
		}
		return renderBuf.toStr
	}

	static Str renderBody() {
		renderBuf	:= null as StrBuf
		bodyFunc	:= peek.bodyFunc
		if (bodyFunc == null)
			return ""
		
		parent  := EfanRenderingStack.peekParent(true, "Could not render body - there is no enclosing template!")
		
		EfanRenderingStack.withCtx("Body") |EfanRenderingStackElement element| {
			// copy the ctx down from the parent
			element.ctx	= parent.ctx.dup

			parentCtx	:= parent.ctx["efan.renderCtx"] as EfanRendererCtx
			renderBuf	= StrBuf(parentCtx.efanMeta.templateSrc.size)
			element.ctx["efan.renderCtx"] = EfanRendererCtx(parentCtx.rendering, renderBuf, null)
				
			convertErrs(parentCtx.efanMeta, bodyFunc)
		}
		return renderBuf.toStr
	}

	static EfanRendererCtx? peek(Bool checked := true) {
		EfanRenderingStack.peek(checked)?.ctx?.get("efan.renderCtx")
	}

	private static Void convertErrs(EfanMeta efanMetaData, |Obj?| func) {
		try {
			// TODO: Dodgy Fantom Syntax! See EfanRender.render()
			// currently, there is no 'it' so we just pass in a number
			func.call(69)
			
		} catch (EfanCompilationErr err) {
			throw err

		} catch (EfanRuntimeErr err) {
			// TODO: I'm not sure if it's helpful to trace through all templates...? 
			throw err

		} catch (Err err) {
			// TODO does this still work for nested renedering
//			rType	:= peek.rendering.typeof
//			regex 	:= Regex.fromStr("^\\s*?${rType.qname}\\._efan_render\\s\\(${rType.pod.name}:([0-9]+)\\)\$")
//			trace	:= err.traceToStr
//			codeLineNo := trace.splitLines.eachWhile |line -> Int?| {
//				reggy 	:= regex.matcher(line)
//				return reggy.find ? reggy.group(1).toInt : null
//			} ?: throw err
//
//			throw efanMetaData.efanRuntimeErr(err, codeLineNo)

			throw efanMetaData.efanRuntimeErr(err)
		}
	}
}

** Saved on the rendering stack, so we know what's currently being rendered
@NoDoc	// used by the compiled template to access the renderBuf 
class EfanRendererCtx {
	EfanComponent	rendering
	|->|? 			bodyFunc
	StrBuf			renderBuf

	new make(EfanComponent rendering, StrBuf renderBuf, |->|? bodyFunc) {
		this.rendering	= rendering
		this.bodyFunc 	= bodyFunc
		this.renderBuf	= renderBuf
	}

	EfanMeta efanMeta() {
		rendering.efanMeta
	}
}
