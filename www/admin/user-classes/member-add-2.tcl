#  www/[ec_url_concat [ec_url] /admin]/user-classes/member-add-2.tcl
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

# we need them to be logged in
set admin_user_id [ad_verify_and_get_user_id]

if {$admin_user_id == 0} {
    
    set return_url "[ad_conn url]?[export_entire_form_as_url_vars]"

    ad_returnredirect "/register.tcl?[export_url_vars return_url]"
    return
}



# see if they're already in ec_user_class_user_map, in which case just update
# their record

if { [db_string get_ucm_count "select count(*) from ec_user_class_user_map where user_id=:user_id and user_class_id=:user_class_id"] > 0 } {
    db_dml update_ec_user_class_map "update ec_user_class_user_map
set user_class_approved_p='t', last_modified=sysdate, last_modifying_user=:admin_user_id, modified_ip_address='[DoubleApos [ns_conn peeraddr]]'
where user_id=:user_id and user_class_id=:user_class_id"
} else {
    db_dml insert_new_ucm_mapping "insert into ec_user_class_user_map
(user_id, user_class_id, user_class_approved_p, last_modified, last_modifying_user, modified_ip_address) 
values
(:user_id, :user_class_id, 't', sysdate, :user_id, '[DoubleApos [ns_conn peeraddr]]')
"
}
db_release_unused_handles
ad_returnredirect "one.tcl?[export_url_vars user_class_id user_class_name]"
