# /www/[ec_url_concat [ec_url] /admin]/orders/fulfillment.tcl
ad_page_contract {
  Order fulfillment page.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id fulfillment.tcl,v 3.2.2.3 2000/08/16 18:49:05 seb Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
}

ad_require_permission [ad_conn package_id] admin

doc_body_append "[ad_admin_header "Order Fulfillment"]

<h2>Order Fulfillment</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index" "Orders"] "Fulfillment"]

<hr>
(these <a href=\"fulfillment-items-needed\">items</a> are needed in order to fulfill all outstanding orders)
<p>
"

set old_order_state ""
set old_shipping_method ""

db_foreach orders_select "
    select o.order_id, o.confirmed_date, o.order_state, o.shipping_method,
           u.first_names, u.last_name, u.user_id
      from ec_orders_shippable o, cc_users u
     where o.user_id=u.user_id
  order by o.shipping_method, o.order_state, o.order_id
" {
    if { $shipping_method != $old_shipping_method } {
	if { $old_shipping_method != "" } {
	    doc_body_append "</ul>
	    </blockquote>"
	}

	doc_body_append "<h3>[string toupper "$shipping_method shipping"]</h3>
	<blockquote>"
    }

    if { $order_state != $old_order_state || $shipping_method != $old_shipping_method } {
	if { $shipping_method == $old_shipping_method } {
	    doc_body_append "</ul>"
	}
	doc_body_append "<b>Orders in state '$order_state'</b>
	<ul>
	"
    }

    doc_body_append "<li>"
    doc_body_append "[ec_order_summary_for_admin $order_id $first_names $last_name $confirmed_date $order_state $user_id]"
    doc_body_append " \[<a href=\"fulfill?order_id=$order_id\">Fulfill</a>\]\n"

    set old_shipping_method $shipping_method
    set old_order_state $order_state
}

if { $old_shipping_method != "" } {
    doc_body_append "
    </ul>
    </blockquote>
    "
}

doc_body_append "[ad_admin_footer]
"
