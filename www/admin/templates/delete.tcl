#  www/[ec_url_concat [ec_url] /admin]/templates/delete.tcl
ad_page_contract {
    @param template_id
  @author
  @creation-date
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    template_id:integer
}

ad_require_permission [ad_conn package_id] admin

# check if this is the template that the admin has assigned as the default
# in which case they'll have to select a new default before they can delete
# this one
set default_template_id [db_string get_default_id "select default_template
from ec_admin_settings"]

if { $template_id == $default_template_id } {
    ad_return_complaint 1 "<li>You cannot delete this template because it is the default template that 
    products will be displayed with if they are not set to be displayed with a different template.
    <br><br>
    If you want to delete this template, you can do so by first setting a different template to
    be the default template.  (To do this, go to a different template and click \"Make this template
    be the default template\".)</li>"
    return
}

set title "Confirm Deletion"
set context [list [list index "Product Templates"] $title]

set export_form_vars_html [export_form_vars template_id]
