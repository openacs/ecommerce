#  www/ecommerce/order.tcl
ad_page_contract {
    Displays an order for the user
    @param order_id:integer
    @param usca_p:optional
  @author
  @creation-date
  @cvs-id order.tcl,v 3.2.2.6 2000/08/18 21:46:34 stevenp Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    order_id:integer
    usca_p:optional

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



ec_create_new_session_if_necessary [export_url_vars order_id]

ec_log_user_as_user_id_for_this_session

set order_summary "<pre>
Order #:
$order_id

Status:
[ec_order_status $order_id]
</pre>

[ec_order_summary_for_customer $order_id $user_id "t"]
"

ec_return_template
