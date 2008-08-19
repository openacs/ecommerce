#  www/[ec_url_concat [ec_url] /admin]/templates/add-2.tcl
ad_page_contract {
    @param template the template
    @param template_name the name of the template

  @author
  @creation-date
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    template_name
    template:allhtml
}

ad_require_permission [ad_conn package_id] admin

set exception_count 0
set exception_text ""

if { ![info exists template] || [empty_string_p $template] } {
    incr exception_count
    append exception_text "<li>The ADP template is empty. Backup and try again.</li>"
}

set f [ec_adp_function_p $template]
if {$f != 0} {
    incr exception_count
    append exception_text "<li>We found <tt>$function</tt> in this template.  
    For security reasons, the templates added here cannot
    have functions in them. Only HTML and <%= \$variable %> style code may be used.</li>"
}

if { $exception_count > 0 } {
    ad_return_complaint $exception_count $exception_text
    return
}

set title "Confirm Template"
set context [list [list index "Product Templates"] $title]

set template_id [db_nextval ec_template_id_sequence]

set export_form_vars_html [export_form_vars template_id template_name template]

db_release_unused_handles
