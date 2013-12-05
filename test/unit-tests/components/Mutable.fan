
@NoDoc @Component
const mixin Mutable {
	@AfterRender
	Void afterRender(StrBuf renderBuf) {
		renderBuf.clear
		renderBuf.add("All change please!")
	}
}
