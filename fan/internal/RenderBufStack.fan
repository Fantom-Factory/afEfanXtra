
@NoDoc
class RenderBufStack {
	private static const Str stackId	:= "efanXtra.renderBuf"

	static Obj? push(|StrBuf->Obj?| func) {		
		currentBuf	:= peek(false) ?: StrBuf()
		return ThreadStack.push(stackId, currentBuf, func)
	}

	static StrBuf? peek(Bool checked := true) {
		ThreadStack.peek(stackId, checked)
	}
}
