using afIoc::Inject

const mixin EfanExtra {
	
	abstract Str[]		libraries()
	
	abstract Type[]		componentTypes(Str prefix)

	abstract Component	createComponent(Type componentType)
}

internal const class EfanExtraImpl : EfanExtra {

	@Inject	private const EfanLibraries efanLibraries
	@Inject	private const ComponentCache componentCache
	
	new make(|This|in) { in(this) }

	override Str[] libraries() {
		efanLibraries.libraries.keys.sort
	}
	
	override Type[] componentTypes(Str prefix) {
		efanLibraries.componentTypes(prefix).sort
	}
	
	override Component createComponent(Type componentType) {
		componentCache.createInstance(componentType)
	}

}
