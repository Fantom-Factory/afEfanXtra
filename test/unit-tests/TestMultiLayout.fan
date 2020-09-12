
internal class TestMultipleLayoutRendering : EfanTest {

	Void testMultipleLayoutRendering() {
		// Bugfix - StackOverflow err
		text := render(T_MultiLayout_Page#)
		echo(text)
		verifyEq(text, 
"PAGE START
   LayoutWp - before
     LayoutWc - before

       LayoutWpBody - before

         pageBody

       LayoutWpBody - after
 
     LayoutWc - after
   LayoutWp - after
 PAGE END
 ")
	}
}

** template: efan
** PAGE START
** <%= app.renderT_MultiLayout_LayoutWp { %>
**         pageBody
** <% } %>
** PAGE END
class T_MultiLayout_Page : EfanComponent { }

** template: efan
** 
**   LayoutWp - before
** <%= app.renderT_MultiLayout_LayoutWc { %>
**       LayoutWpBody - before
** <%= renderBody %>
**       LayoutWpBody - after
** <% } %>
**   LayoutWp - after
** 
class T_MultiLayout_LayoutWp : EfanComponent { }

** template: efan
** 
**     LayoutWc - before
** <%= renderBody %>
**     LayoutWc - after
** 
class T_MultiLayout_LayoutWc : EfanComponent { }
