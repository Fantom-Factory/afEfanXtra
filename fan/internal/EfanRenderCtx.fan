using concurrent::Actor
using afEfan::EfanErr

@NoDoc	// needs to be called from compiled pods
class EfanRenderCtx {
	private static const Str		localId		:= "efan.renderCtx"
	
	Str					renderId
	EfanRenderCtx?		parent		{ private set }
	EfanComponent		rendering	{ private set }
	Func? 				bodyFunc	//{ private set }
	private [Str:Obj?]?	_vars		{ private set }
	private StrBuf?		_renderBuf

	internal new make(EfanComponent rendering, Func? bodyFunc) {
		this.renderId	= rendering.componentId
		this.rendering	= rendering
		this.bodyFunc	= bodyFunc
	}

	Obj? runInCtx(|EfanRenderCtx -> Obj?| func) {
		this.parent = peek(false)	// false 'cos we may be the first!
		Actor.locals[localId] = this
		try	  				return func.call(this)
		catch (EfanErr err)	throw err
		catch (Err err)		throw rendering.efanMeta.efanRuntimeErr(err)
		finally {
			if (this.parent == null)
				Actor.locals.remove(localId)
			else
				Actor.locals[localId] = this.parent
			this.parent = null
		}
	}

	StrBuf renderBuf() {
		if (_renderBuf == null)
			_renderBuf = StrBuf(rendering.efanMeta.templateSrc.size)
		return _renderBuf
	}

	Uri path() {
		(parent?.path ?: `/`).plusSlash.plusName(renderId)
	}
	
	This dup() {
		EfanRenderCtx(rendering, bodyFunc) {
			it._vars	= this._vars
			it.renderId += "(Body)" 
		}
	}

	Void setVar(Str name, Obj? value) {
		echo("setting [$name] on $path")
		if (_vars == null)
			if (value == null) return; else _vars = Str:Obj?[:]
		_vars[name] = value
	}
	
	Obj? getVar(Str name) {
		echo("getting [$name] fo $path")
		return _vars?.get(name)
	}

	Bool hasVar(Str name) {
		_vars == null ? false : _vars.containsKey(name)
	}
	
	static EfanRenderCtx? peek(Bool checked := true) {
		echo(Actor.locals[localId]?->path)
		return Actor.locals[localId] ?: (checked ? throw Err("Could not find EfanRenderCtx in Actor.locals()") : null)		
	}
	
	override Str toStr() { rendering.componentId }
}
