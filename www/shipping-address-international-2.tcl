#  www/ecommerce/shipping-address-international-2.tcl
ad_page_contract {
    @param attn
    @param line1
    @param line2:optional
    @param city 
    @param full_state_name:optional
    @param zip_code:optional
    @param country_code
    @param phone
    @param phone_time:optional
  @author
  @creation-date
  @cvs-id shipping-address-international-2.tcl,v 3.2.6.9 2000/08/18 21:46:35 stevenp Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    attn:notnull
    line1:notnull
    line2:optional
    city:notnull
    full_state_name:optional
    zip_code:optional
    country_code:notnull
    phone
    phone_time:optional
}


set possible_exception_list [list [list attn name] [list line1 address] [list city city] [list country_code country] [list phone "telephone number"]]

set exception_count 0
set exception_text ""

foreach possible_exception $possible_exception_list {
    if { ![info exists [lindex $possible_exception 0]] || [empty_string_p [set [lindex $possible_exception 0]]] } {
	incr exception_count
	append exception_text "<li>You forgot to enter your [lindex $possible_exception 1]."
    }
}

if { $exception_count > 0 } {
    ad_return_complaint $exception_count $exception_text
    return
}

# we need them to be logged in
set user_id [ad_verify_and_get_user_id]

if {$user_id == 0} {
    
    set return_url "[ad_conn url]?[export_entire_form_as_url_vars]"

    ad_returnredirect "/register?[export_url_vars return_url]"
    return
}

# make sure they have an in_basket order, otherwise they've probably
# gotten here by pushing Back, so return them to index.tcl

set user_session_id [ec_get_user_session_id]



set order_id [db_string get_order_id "select order_id from ec_orders where user_session_id=:user_session_id and order_state='in_basket'" -default ""]

if { [empty_string_p $order_id] } {
    # then they probably got here by pushing "Back", so just redirect them
    # to index.tcl
    ad_returnredirect index.tcl
    return
}

set address_id [db_string get_address_id_from_seq "select ec_address_id_sequence.nextval from dual"]

db_transaction {

    db_dml insert_new_address "insert into ec_addresses
    (address_id, user_id, address_type, attn, line1, line2, city, full_state_name, zip_code, country_code, phone, phone_time)
    values
    (:address_id, :user_id, 'shipping', :attn, :line1,:line2,:city,:full_state_name,:zip_code,:country_code,:phone,:phone_time)
    "

    db_dml update_order_shipping_address "update ec_orders set shipping_address=:address_id where order_id=:order_id"

}
db_release_unused_handles

#  array set drivers [ec_preferred_drivers]
#  if { [ad_ssl_available_p] } {
#      set ssl_port [ns_config -int "ns/server/[ns_info server]/module/$drivers(sdriver)" Port 443]
#      if { $ssl_port == 443 } {
#          set ssl_port ""
#      } else {
#          set ssl_port ":$ssl_port"
#      }
#      ad_returnredirect "https://[ns_config ns/server/[ns_info server]/module/$drivers(sdriver) Hostname]${ssl_port}[ec_url]checkout-2"
#  } else {
#      ad_returnredirect "http://[ns_config ns/server/[ns_info server]/module/$drivers(driver) Hostname][ec_url]checkout-2"
#  }

ad_returnredirect [ec_securelink [ec_url]checkout-2]
