using afIoc::Inject
using afEfan

@NoDoc
@Component
const mixin Page {
	
	@Inject abstract AfVersion version
	
}
