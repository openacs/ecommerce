ad_page_contract {
    @param user_class_id ID of the user class
    @param usca_p User session begun or not

    @author
    @creation-date
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse <bart.teeuwisse@7-sisters.com>
    @revision-date April 2002

} {
    user_class_id:multiple
    usca_p:optional
}

set user_class_id_list $user_class_id
set user_id [ad_verify_and_get_user_id]
set ip_address [ns_conn peeraddr]
if {$user_id == 0} {
    set return_url "[ad_conn url]"
    ad_returnredirect "/register?[export_url_vars return_url]"
    ad_script_abort
}

set user_session_id [ec_get_user_session_id]
ec_create_new_session_if_necessary
ec_log_user_as_user_id_for_this_session

# update User Class

db_transaction {

    # Get old user_class_ids

    set old_user_class_id_list [db_list get_old_class_ids "
	select user_class_id 
    	from ec_user_class_user_map 
    	where user_id = :user_id"]

    # Add the user_class if it is not already there

    foreach user_class_id $user_class_id_list {
	if { [lsearch -exact $old_user_class_id_list $user_class_id] == -1 && ![empty_string_p $user_class_id] } {
	    if [catch { db_dml insert_user_class "
		insert into ec_user_class_user_map 
      		(user_id, user_class_id, user_class_approved_p, last_modified, last_modifying_user, modified_ip_address) 
      		values 
      		(:user_id, :user_class_id, null, sysdate, :user_id, :ip_address)" } errmsg] {
		ad_return_error "Ouch!" "The database choked on our update:
		<blockquote>
		  $errmsg
		</blockquote>"
	    }
	}
    }

    # Delete the user_class if it is not in the new list
    foreach old_user_class_id $old_user_class_id_list {
	if { [lsearch -exact $user_class_id_list $old_user_class_id] == -1 && ![empty_string_p $old_user_class_id] } {
	    set sql "delete from ec_user_class_user_map 
	    where user_id = :user_id 
	    and user_class_id = :old_user_class_id"
	    
	    if [catch { db_dml delete_from_user_class_map $sql } errmsg] {
		ad_return_error "Ouch!" "The database choked on our update:
		<blockquote>
		$errmsg
		</blockquote>
		"
	    }
	    ec_audit_delete_row [list $user_id $old_user_class_id] [list user_id user_class_id] ec_user_class_user_map_audit
	}
    }
    
}
db_release_unused_handles

rp_internal_redirect "account"
