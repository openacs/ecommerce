# gift-certificate-edit.tcl

ad_page_contract { 
    @param user_id
    @param gift_certificate_id
    @param expires

    @author
    @creation-date
    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    user_id
    gift_certificate_id
    expires
}

ad_require_permission [ad_conn package_id] admin

set customer_service_rep [ad_get_user_id]

if {$customer_service_rep == 0} {
    ad_returnredirect "/register.tcl?[export_url_vars return_url]"
    return
}


set address [ns_conn peeraddr]
db_dml update_ec_gc_info "update ec_gift_certificates
set expires=sysdate, last_modified=sysdate, last_modifying_user=:customer_service_rep, 
modified_ip_address= :address
where gift_certificate_id=:gift_certificate_id"
db_release_unused_handles
ad_returnredirect "gift-certificates.tcl?[export_url_vars user_id]"
