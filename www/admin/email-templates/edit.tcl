# edit.tcl

ad_page_contract {
    @param  email_template_id
    @author
    @creation-date
    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    email_template_id
}

ad_require_permission [ad_conn package_id] admin

set title "Edit Email Template"
set context [list [list index "Email Templates"] $title]

set export_form_vars_html [export_form_vars email_template_id]

if { ![db_0or1row unused "select * from ec_email_templates where email_template_id=:email_template_id"] } {
    ad_return_complaint 1 "Invalid email_template_id passed in"
    return
}

db_release_unused_handles

set issue_type_widget_html [ec_issue_type_widget $issue_type_list]

set table_names_and_id_column [list ec_email_templates ec_email_templates_audit email_template_id]

# Set audit variables
# audit_id_column, return_url, audit_tables, main_tables
set audit_id_column "email_template_id"
set return_url "[ad_conn url]?[export_entire_form_as_url_vars]"
set audit_tables [list ec_email_templates_audit]
set main_tables [list ec_email_templates]
set audit_name "Email Template: $title"
set audit_id $email_template_id
set audit_url_html "[ec_url_concat [ec_url] /admin]/audit?[export_url_vars audit_name audit_id audit_id_column return_url audit_tables main_tables]"

