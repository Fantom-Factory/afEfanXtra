using afEfan::EfanRenderer

** Allows you to explicitly set a template for your component.
** By default, 'afEfanExtra' looks for an efan template with the same name as the component class. 
@FacetMeta { inherited = true }
facet class EfanTemplate {	

	** Use to explicitly set the location of the efan template. The Uri may take several forms:
	**  - if fully qualified, the template is resolved, e.g. 'fan://acmePod/templates/Notice.efan' 
	**  - if relative, the template is assumed to be on the file system, e.g. 'etc/templates/Notice.efan' 
	**  - if absolute, the template is assumed to be a pod resource, e.g. '/templates/Notice.efan'
	const Uri? uri
}
