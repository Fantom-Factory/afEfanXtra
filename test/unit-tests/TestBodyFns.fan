
internal class TestBodyFns : EfanTest {

	Void testBasicBodyFnRendering() {
		// Bugfix - StackOverflow err
		text := render(T_BodyTest1_Page#)
		echo(text)
		verifyEq(text, 
"PAGE START
   Layout - before

     pageBody

   Layout - after
 PAGE END
 ")
	}
}

** template: efan
** PAGE START
** <%= app.renderT_BodyTest1_Layout { %>
**     pageBody
** <% } %>
** PAGE END
class T_BodyTest1_Page : EfanComponent { }

** template: efan
** 
**   Layout - before
** <%= renderBody %>
**   Layout - after
** 
class T_BodyTest1_Layout : EfanComponent { }
