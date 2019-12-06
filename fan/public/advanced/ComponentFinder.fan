using afEfan::EfanErr

@NoDoc
const mixin ComponentFinder {
	abstract Type[] findComponentTypes(Pod pod)
}

internal const class ComponentFinderImpl : ComponentFinder {
	override Type[] findComponentTypes(Pod pod) {
		pod.types.findAll |t| {
			if (t == EfanComponent#)
				return false
			if (!t.fits(EfanComponent#))
				return false
			if (t.hasFacet(Abstract#))
				return false
			if (t.isClass && t.isAbstract)
				return false
			return true
		}
	}
}
