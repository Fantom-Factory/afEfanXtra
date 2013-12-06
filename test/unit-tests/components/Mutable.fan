
@NoDoc
const mixin Mutable : EfanComponent {
	@AfterRender
	Void afterRender(StrBuf renderBuf) {
		renderBuf.clear
		renderBuf.add("All change please!")
	}
}
