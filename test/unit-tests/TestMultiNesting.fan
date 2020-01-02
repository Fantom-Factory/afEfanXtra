
internal class TestNestedBodyRendering : EfanTest {

	Void testNestedBodyRendering() {
		text := render(T_MultiNest_Page#)
		echo(text)
		verifyEq(text, 
"PAGE START
   Layout - before
 
     pageBody - before
       Com - before
 
         pageBody - body
 
       Com - after
     pageBody - after
 
   Layout - after
 PAGE END
 ")
	}
}

** template: efan
** PAGE START
** <%= app.renderT_MultiNest_Layout { %>
**     pageBody - before
** <%= app.renderT_MultiNest_Com { %>
**         pageBody - body
** <% } %>
**     pageBody - after
** <% } %>
** PAGE END
@NoDoc
const mixin T_MultiNest_Page : EfanComponent { }

** template: efan
** 
**   Layout - before
** <%= renderBody %>
**   Layout - after
** 
@NoDoc
const mixin T_MultiNest_Layout : EfanComponent { }

** template: efan
** 
**       Com - before
** <%= renderBody %>
**       Com - after
** 
@NoDoc
//** <%= renderBody %>
const mixin T_MultiNest_Com : EfanComponent { }
