#  www/[ec_url_concat [ec_url] /admin]/user-classes/member-delete.tcl
ad_page_contract {
    @param user_class_id
    @param user_class_name
    @param user_id
  @author
  @creation-date
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    user_class_id:naturalnum
    user_class_name
    user_id:naturalnum
}

ad_require_permission [ad_conn package_id] admin

set title "Remove Member from $user_class_name"
set context [list [list index "User Classes"] $title]

set export_form_vars_html [export_form_vars user_class_id user_class_name user_id]
