#  www/ecommerce/gift-certificate-claim.tcl
ad_page_contract {

  @author
  @creation-date
  @cvs-id gift-certificate-claim.tcl,v 3.1.6.6 2000/08/18 21:46:33 stevenp Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
}


# we need them to be logged in
set user_id [ad_verify_and_get_user_id]

if {$user_id == 0} {
    set return_url "[ad_conn url]"

    ad_returnredirect "/register?[export_url_vars return_url]"
    return
}



# make sure they have an in_basket order and a user_session_id;
# this will make it more annoying for someone who just wants to
# come to this page and try random number after random number

set user_session_id [ec_get_user_session_id]

if { $user_session_id == 0 } {
    ad_returnredirect "index"
    return
}

set order_id [db_string get_order_id_for_claim "select order_id from ec_orders where user_session_id=:user_session_id and order_state='in_basket'" -default ""]
if { [empty_string_p $order_id] } {
    ad_returnredirect "index"
    return
}

ec_return_template
