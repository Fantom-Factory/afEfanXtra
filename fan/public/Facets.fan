
** Place on component classes to explicitly use a named template file.
** By default, 'efanXtra' looks for an efan template with the same name as the component class. 
@FacetMeta { inherited = true }
facet class TemplateLocation {	

	** Use to explicitly set the location of the efan template. The Url may take several forms:
	**  - if fully qualified, the template is resolved, e.g. 'fan://acmePod/templates/Notice.efan' 
	**  - if relative, the template is assumed to be on the file system, e.g. 'etc/templates/Notice.efan' 
	**  - if absolute, the template is assumed to be a pod resource, e.g. '/templates/Notice.efan'
	const Uri? url
}

** Place on 'abstract' base components to tell 'efanExta' not to treat it as a component. Example:
** 
**   syntax: fantom
** 
**   using afEfanExtra
** 
**   @Abstract
**   const mixin MyComponent : EfanComponent { ... }
** 
** Because components are mixins, 'efanXtra' has no other way to differentiate between real components and base classes! 
facet class Abstract { }

** Use to mark a component lifecycle method. Init render methods may take any number of parameters. Example:
** 
**   syntax: fantom
** 
**   @InitRender
**   Bool? initRender(Str x, Int y) { ... }
** 
** Param types may be nullable.
facet class InitRender { }

** Use to mark a component lifecycle method. 
** Before render methods may optionally define a 'StrBuf' parameter. 
** You can use this to change any part of the current rendering.
** 
**   syntax: fantom
** 
**   @BeforeRender
**   Bool? beforeRender(StrBuf output) { ... }
** 
** If the method returns 'false' then rendering is skipped and '@AfterRender' is called.
facet class BeforeRender { }

** Use to mark a component lifecycle method.
** After render methods may optionally define a 'StrBuf' parameter. 
** You can use this to change any part of the current rendering.
** 
**   syntax: fantom
** 
**   @AfterRender
**   Bool? afterRender(StrBuf output) { ... }
** 
** If the method returns 'false' then the lifecyle returns back to '@BeforeRender'.
facet class AfterRender { }

