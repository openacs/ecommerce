#  www/ecommerce/shipping-address.tcl
ad_page_contract {
    @param usca_p:optional
  @creation-date
  @cvs-id address-delete.tcl
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    usca_p:optional
    return_url
    address_id:integer
}

# we need them to be logged in
set user_id [ad_verify_and_get_user_id]

if {$user_id == 0} {
    
    set return_url "[ad_conn url]"

    ad_returnredirect "/register?[export_url_vars return_url]"
    return
}

# user session tracking
set user_session_id [ec_get_user_session_id]

ec_create_new_session_if_necessary
# type1

ec_log_user_as_user_id_for_this_session

db_dml delete-address "
delete from ec_addresses
      where user_id = :user_id
        and address_id = :address_id
"
ad_returnredirect $return_url

