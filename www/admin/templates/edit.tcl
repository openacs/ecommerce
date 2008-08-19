#  www/[ec_url_concat [ec_url] /admin]/templates/edit.tcl
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

db_1row get_template_info "select template_name, template from ec_templates where template_id=:template_id"

set title  "Edit Template"
set context [list [list index "Product Templates"] $title]

set export_form_vars_html [export_form_vars template_id]

db_release_unused_handles

