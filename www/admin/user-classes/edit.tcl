#  www/[ec_url_concat [ec_url] /admin]/user-classes/edit.tcl
ad_page_contract {
    @param user_class_name
    @param user_class_id

  @author
  @creation-date
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    user_class_name
    user_class_id:naturalnum
}

ad_require_permission [ad_conn package_id] admin

db_dml update_ec_user_classes "update ec_user_classes
set user_class_name=:user_class_name
where user_class_id=:user_class_id"
db_release_unused_handles
ad_returnredirect "one.tcl?[export_url_vars user_class_id user_class_name]"