# gift-certificate-add-2.tcl

ad_page_contract { 
    @param user_id
    @param amount
    @param expires
    @author
    @creation-date
    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {


    user_id:notnull,naturalnum
    amount:notnull
    expires
}

ad_require_permission [ad_conn package_id] admin

# 

set expires_to_insert [ec_decode $expires "" "null" $expires]

set customer_service_rep [ad_get_user_id]

if {$customer_service_rep == 0} {
    set return_url "[ad_conn url]?[export_entire_form_as_url_vars]"
    ad_returnredirect "/register.tcl?[export_url_vars return_url]"
    return
}



# put a record into ec_gift_certificates
# and add the amount to the user's gift certificate account
set address [ns_conn peeraddr]
db_dml insert_new_ec_gift_cert "insert into ec_gift_certificates
(gift_certificate_id, user_id, amount, expires, issue_date, issued_by, gift_certificate_state, last_modified, last_modifying_user, modified_ip_address)
values
(ec_gift_cert_id_sequence.nextval, :user_id, :amount, :expires_to_insert, sysdate, :customer_service_rep, 'authorized', sysdate, :customer_service_rep, address)
"
db_release_unused_handles

ad_returnredirect "gift-certificates.tcl?[export_url_vars user_id]"
