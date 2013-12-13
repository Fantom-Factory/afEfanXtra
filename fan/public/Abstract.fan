
** Place on 'abstract' base components to tell 'efanExta' not to treat it as a component. Example:
** 
**   using afEfanExtra
** 
**   @Abstract
**   const mixin MyComponent : EfanComponent { ... }
** 
** Because components are mixins, 'efanXtra' has no other way to differentiate between real components and base classes! 
facet class Abstract { }
