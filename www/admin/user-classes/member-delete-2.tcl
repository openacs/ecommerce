#  www/[ec_url_concat [ec_url] /admin]/user-classes/member-delete-2.tcl
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

db_dml delete_user_from_eccmap "delete from ec_user_class_user_map where user_id=:user_id and user_class_id=:user_class_id"

ec_audit_delete_row [list $user_class_id $user_id] [list user_class_id user_id] ec_user_class_user_map_audit
db_release_unused_handles

ad_returnredirect "members.tcl?[export_url_vars user_class_id user_class_name]"
