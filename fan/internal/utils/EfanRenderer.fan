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
		bodyFunc	:= peek.bodyFunc
		if (bodyFunc == null)
			return ""
		
		parent  := EfanRenderingStack.peekParent(true, "Could not render body - there is no enclosing template!")

		renderBuf	:= null as StrBuf
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
			// Dodgy Fantom Syntax! See EfanRender.render()
			// currently, there is no 'it' so we just pass in a number
			func.call(69)
			
		} catch (EfanCompilationErr err) {
			throw err

		} catch (EfanRuntimeErr err) {
			throw err

		} catch (Err err) {
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
