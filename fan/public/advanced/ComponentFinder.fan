using afEfan::EfanErr

@NoDoc
const mixin ComponentFinder {
	abstract Type[] findComponentTypes(Pod pod)
}

internal const class ComponentFinderImpl : ComponentFinder {
	override Type[] findComponentTypes(Pod pod) {
		components := pod.types.findAll { it.fits(EfanComponent#) && !it.hasFacet(Abstract#) }
		components.each { if (!it.isMixin) { throw Err(ErrMsgs.componentNotMixin(it)) } } 
		components.each { if (!it.isConst) { throw Err(ErrMsgs.componentNotConst(it)) } }
		return components
	}
}
