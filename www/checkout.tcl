# /www/ecommerce/checkout.tcl
ad_page_contract {
    @param usca_p:optional

    @author
    @creation-date
    @cvs-id checkout.tcl,v 3.4.2.10 2000/10/31 14:03:13 elorenzo Exp
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    usca_p:optional
}

# rolled login requirement into  ec_redirect_to_https_if_possible_and_necessary
ec_redirect_to_https_if_possible_and_necessary

# make sure they have an in_basket order, otherwise they've probably
# gotten here by pushing Back, so return them to index.tcl

set user_id [ad_verify_and_get_user_id]
set user_session_id [ec_get_user_session_id]
ec_create_new_session_if_necessary

ec_log_user_as_user_id_for_this_session

set order_id [db_string  get_order_id "select order_id from ec_orders where user_session_id=:user_session_id and order_state='in_basket'" -default "" ]

if { [empty_string_p $order_id] } {
    # then they probably got here by pushing "Back", so just redirect them
    # to index.tcl
    ad_returnredirect index
    template::adp_abort
} else {
    db_dml update_ec_order_set_uid "update ec_orders set user_id=:user_id where order_id=:order_id"
}

# check whether or not shipping is available
set shipping_unavail_p [db_string check_order_shippable "
        select count(*)
        from dual
        where exists (select 1
                      from ec_products p, ec_items i
                      where i.product_id = p.product_id
                      and i.order_id = :order_id
                      and no_shipping_avail_p = 't')"]

# see if there are any saved shipping addresses for this user
set saved_addresses "
You can select an address listed below or enter a new address.
<table border=0 cellspacing=0 cellpadding=20>
"

# Present all saved addresses
db_foreach get_user_addresses "
select address_id, attn,
       line1,
       line2,
       city, usps_abbrev, zip_code,
       phone, country_code, full_state_name,
       phone_time
  from ec_addresses
 where user_id=:user_id
   and address_type='shipping'
" {

    # Present a single saved address
    append saved_addresses "
    <tr>
      <td>[ec_display_as_html [ec_pretty_mailing_address_from_args $line1 $line2 $city $usps_abbrev $zip_code $country_code $full_state_name $attn $phone $phone_time]]</td>
      <td><p><a href=\"checkout-2?[export_url_vars address_id]\">\[use this address\]</a><br>
          <a href=\"shipping-address?[export_url_vars address_id]\">\[edit this address\]</a><br>
          <a href=\"delete-shipping-address?[export_url_vars address_id]\">\[delete this address\]</a></p></td>
    </tr>
    "

} if_no_rows {
    set saved_addresses ""
}

# Add closing table tag if there are saved addresses
if {![empty_string_p $saved_addresses] } {
    append saved_addresses "
    </table>
    "
}

db_release_unused_handles
ec_return_template
