
internal class TestComBug : EfanTest {

	// this bug is a Fantom one - see  - see https://fantom.org/forum/topic/2216
	// and was actually fixed in afPlastic
	Void testComBug() {
//		Pod.find("afEfan").log.level = LogLevel.debug
		
		text := render(ComBug1#)

		verify(text.contains("ComBug1 - start body"))
	}
}
