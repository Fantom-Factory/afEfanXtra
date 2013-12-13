
** Use to mark a component lifecycle method. Init render methods may take any number of parameters. Example:
** 
**   @InitRender
**   Obj? initRender(Str x, Int y) { ... }
** 
** Param types may be nullable.
facet class InitRender { }

** Use to mark a component lifecycle method. 
** Before render methods may optionally define a 'StrBuf' parameter. 
** You can use this to change any part of the current rendering.
** 
**   @BeforeRender
**   Bool? beforeRender(StrBuf output) { ... }
** 
** If the method returns 'false' then rendering is skipped and @AfterRender is called.
facet class BeforeRender { }

** Use to mark a component lifecycle method.
** After render methods may optionally define a 'StrBuf' parameter. 
** You can use this to change any part of the current rendering.
** 
**   @AfterRender
**   Bool? afterRender(StrBuf output) { ... }
** 
** If the method returns 'false' then the lifecyle returns back to @BeforeRender.
facet class AfterRender { }

