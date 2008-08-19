#  www/[ec_url_concat [ec_url] /admin]/user-classes/one.tcl
ad_page_contract {
    @param user_class_id
    @param user_class_name
  @author
  @creation-date
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    user_class_id:naturalnum
    user_class_name
}

ad_require_permission [ad_conn package_id] admin

set title  "Class $user_class_name"
set context [list [list index "User Classes"] $title]

# Set audit variables
# audit_name, audit_id, audit_id_column, return_url, audit_tables, main_tables
set audit_name "$user_class_name"
set audit_id $user_class_id
set audit_id_column "user_class_id"
set return_url "[ad_conn url]?[export_url_vars user_class_id user_class_name]"
set audit_tables [list ec_user_classes_audit]
set main_tables [list ec_user_classes]

set export_form_user_class_id_html [export_form_vars user_class_id]
set export_form_user_class_name_id_html [export_url_vars user_class_id user_class_name]
set audit_url_html [ec_url_concat [ec_url] /admin]/audit?[export_url_vars audit_name audit_id audit_id_column return_url audit_tables main_tables]
