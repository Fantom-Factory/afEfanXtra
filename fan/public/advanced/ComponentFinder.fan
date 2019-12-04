using afEfan::EfanErr

@NoDoc
const mixin ComponentFinder {
	abstract Type[] findComponentTypes(Pod pod)
}

internal const class ComponentFinderImpl : ComponentFinder {
	override Type[] findComponentTypes(Pod pod) {
		pod.types.findAll { it.fits(EfanComponent#) && !it.hasFacet(Abstract#) && it != EfanComponent# }
	}
}
