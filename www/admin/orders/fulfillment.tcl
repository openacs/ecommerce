# /www/[ec_url_concat [ec_url] /admin]/orders/fulfillment.tcl
ad_page_contract {
  Order fulfillment page.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
}

ad_require_permission [ad_conn package_id] admin

set title "Order Fulfillment"
set context [list [list index "Orders / Shipments / Refunds"] $title]

set old_order_state ""
set old_shipping_method ""
set pre_auth_stale_date [clock format [clock scan "4 weeks ago"] -format "%Y-%m-%d"]

set orders_select_html ""
db_foreach orders_select "select o.order_id, o.confirmed_date, o.order_state, o.shipping_method,
           u.first_names, u.last_name, u.user_id
      from ec_orders_shippable o, cc_users u
     where o.user_id=u.user_id
  order by o.shipping_method, o.order_state, o.order_id" {
    if { $shipping_method != $old_shipping_method } {
        if { $old_shipping_method != "" } {
            append orders_select_html "</ul>"
        }
        append orders_select_html "<h3>[string toupper "$shipping_method shipping"]</h3>"
    }
    if { $order_state != $old_order_state || $shipping_method != $old_shipping_method } {
        if { $shipping_method == $old_shipping_method } {
            append orders_select_html "</ul>"
        }
        append orders_select_html "<p><b>Orders in state '$order_state'</b></p><ul>"
    }
    append orders_select_html "<li>"
    if { $pre_auth_stale_date > $confirmed_date } { 
        append orders_select_html "[ec_order_summary_for_admin $order_id $first_names $last_name $confirmed_date $order_state $user_id]"
        append orders_select_html "<b>Stale order<b>. (Contact sitewide admin to extract credit card info when ready to fulfill, or void this order, or do something completely different.)"
    } else {
        append orders_select_html "[ec_order_summary_for_admin $order_id $first_names $last_name $confirmed_date $order_state $user_id]"
        append orders_select_html " \[<a href=\"fulfill?order_id=$order_id\">Fulfill</a>\]\n"
    }
    set old_shipping_method $shipping_method
    set old_order_state $order_state
}

if { $old_shipping_method != "" } {
    append orders_select_html "</ul>"
}
