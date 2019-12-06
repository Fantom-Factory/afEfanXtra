
** This should not be recognised as a component.
@NoDoc @Abstract
const mixin T_MyBaseComponent : EfanComponent { }

** But this should...
@NoDoc
abstract const class T_MyBaseComponent2 : EfanComponent { }
