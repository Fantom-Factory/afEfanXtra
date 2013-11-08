using afEfan::EfanRenderer

// TODO: rename to EfanComponent
** Annotate your efan Components with '@Component'. By default, 'afEfanExtra' looks for an efan 
** template with the same name as the component class. 
@FacetMeta { inherited = true }
facet class Component {	
	
	// TODO: fandoc Component.template
	const Uri? template
	
}
