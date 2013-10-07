using afEfan::EfanErr

@NoDoc
const mixin ComponentFinder {
	abstract Type[] findComponentTypes(Pod pod)
}

internal const class ComponentFinderImpl : ComponentFinder {
	override Type[] findComponentTypes(Pod pod) {
		components := pod.types.findAll { it.hasFacet(Component#) && it != Component# }
		components.each { if (!it.isMixin) { throw EfanErr(ErrMsgs.componentNotMixin(it)) } } 
		components.each { if (!it.isConst) { throw EfanErr(ErrMsgs.componentNotConst(it)) } }
		return components
	}
}
