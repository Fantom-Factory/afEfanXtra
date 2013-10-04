
@NoDoc
const mixin ComponentFinder {
	abstract Type[] findComponentTypes(Pod pod)
}

internal const class ComponentFinderImpl : ComponentFinder {
	override Type[] findComponentTypes(Pod pod) {
		pod.types.findAll { it.hasFacet(Component#) && it.isMixin && it != Component# }		
	}
}
