#  www/[ec_url_concat [ec_url] /admin]/user-classes/add.tcl
ad_page_contract {
    @param user_class_name

  @author
  @creation-date
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    user_class_name:trim,notnull
}

ad_require_permission [ad_conn package_id] admin

set title  "Confirm New User Class"
set context [list [list index "User Classes"] $title]

set user_class_id [db_nextval ec_user_class_id_sequence]

set export_form_vars_html [export_form_vars user_class_name user_class_id]
