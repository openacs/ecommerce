#  www/[ec_url_concat [ec_url] /admin]/user-classes/delete.tcl
ad_page_contract {
    @param  user_class_id
  @author
  @creation-date
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    user_class_id:naturalnum
}

ad_require_permission [ad_conn package_id] admin

set user_class_name [db_string get_ucname "select user_class_name from ec_user_classes where user_class_id=:user_class_id"]

set title "Delete $user_class_name"
set context [list [list index "User Classes"] $title]

set export_form_vars_html [export_form_vars user_class_id]
