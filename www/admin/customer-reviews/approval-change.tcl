# approval-change.tcl

ad_page_contract {
    @author
    @creation-date
    @cvs-id approval-change.tcl,v 3.1.6.6 2000/08/18 21:46:54 stevenp Exp
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
approved_p
comment_id:notnull
}

ad_require_permission [ad_conn package_id] admin

set user_id [ad_get_user_id]

if {$user_id == 0} {
    
    set return_url "[ad_conn url]?[export_entire_form_as_url_vars]"

    ad_returnredirect "/register.tcl?[export_url_vars return_url]"
    return
}


if { [catch {db_dml update_set_approved_satus "update ec_product_comments set 
approved_p=:approved_p,
last_modified = sysdate,
last_modifying_user = :user_id,
modified_ip_address = '[ns_conn peeraddr]'
where comment_id=:comment_id"} errMsg] } {
    ad_return_complaint 1 "Failed to update the comments approval, suspect invalid comment_id"
}

db_release_unused_handles

if { ![info exists return_url] } {
    ad_returnredirect index.tcl
} else {
    ad_returnredirect $return_url
}





