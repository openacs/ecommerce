#  www/[ec_url_concat [ec_url] /admin]/user-classes/approve-toggle.tcl
ad_page_contract {
    @param user_class_id 
    @param user_class_approved_p 
    @param user_id
 Toggles a user_class between approved and unapproved
  @author jkoontz@arsdigita.com 
  @creation-date July 22 1999
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    user_class_id 
    user_class_approved_p 
    user_id
}

ad_require_permission [ad_conn package_id] admin

# we need them to be logged in
set admin_user_id [ad_verify_and_get_user_id]

if {$admin_user_id == 0} {
    
    set return_url "[ad_conn url]?[export_entire_form_as_url_vars]"

    ad_returnredirect "/register.tcl?[export_url_vars return_url]"
    return
}



db_dml update_ec_class_map "update ec_user_class_user_map
set user_class_approved_p=[ec_decode $user_class_approved_p "t" "'f'" "'t'"], last_modified=sysdate, last_modifying_user=:admin_user_id, modified_ip_address='[DoubleApos [ns_conn peeraddr]]'
where user_id=:user_id and user_class_id=:user_class_id"
db_release_unused_handles
ad_returnredirect "members.tcl?[export_url_vars user_class_id]"
