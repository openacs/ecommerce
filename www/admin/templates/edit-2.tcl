#  www/[ec_url_concat [ec_url] /admin]/templates/edit-2.tcl
ad_page_contract {
    @param template_id
    @param template_name
    @param template

  @author
  @creation-date
  @cvs-id edit-2.tcl,v 3.2.2.7 2000/09/22 01:35:04 kevin Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    template_id:integer
    template_name
    template:allhtml
}

ad_require_permission [ad_conn package_id] admin

# check the template for the execution of functions

set f [ec_adp_function_p $template]
if {$f != 0} {
    ad_return_complaint 1 "
    <P>We're sorry, but files edited here cannot
    have functions in them for security reasons. Only HTML and 
    <%= \$variable %> style code may be used.
    This template appears to contain <tt>$f</tt>."
    return
}

db_dml update_ec_templates "update ec_templates
set template_name=:template_name, template=:template
where template_id=:template_id"
db_release_unused_handles

ad_returnredirect index.tcl
