
internal class TestComBug : EfanTest {

	// this bug is a Fantom one - see  - see http://fantom.org/sidewalk/topic/2216
	// and was actually fixed in afPlastic
	Void testComBug() {
		Pod.find("afEfan").log.level = LogLevel.debug
		
		text := efanXtra.render(ComBug1#).toStr

		verify(text.contains("ComBug1 - start body"))
	}
}
