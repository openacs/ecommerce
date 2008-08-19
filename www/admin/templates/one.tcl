#  www/[ec_url_concat [ec_url] /admin]/templates/one.tcl
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

db_1row get_template_data  "select template_name, template from ec_templates where template_id=:template_id"

set default_template_id [db_string get_default_template "select default_template from ec_admin_settings"]

set title  "Template ${template_name}"
set context [list [list index "Product Templates"] $title]

set default_template_p [expr { $template_id == $default_template_id } ]

set export_url_vars_html [export_url_vars template_id]

# Set audit variables
# audit_name, audit_id, audit_id_column, return_url, audit_tables, main_tables
set audit_name "$template_name"
set audit_id $template_id
set audit_id_column "template_id"
set return_url "[ad_conn url]?[export_url_vars template_id]"
set audit_tables [list ec_templates_audit]
set main_tables [list ec_templates]
set audit_url_html "[ec_url_concat [ec_url] /admin]/audit?[export_url_vars audit_name audit_id audit_id_column return_url audit_tables main_tables]"
