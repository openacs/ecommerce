# /www/[ec_url_concat [ec_url] /admin]/orders/items-return-2.tcl
ad_page_contract {

    @cvs-id items-return-2.tcl,v 3.2.6.9 2000/09/22 01:34:57 kevin Exp
    @author ported by Jerry Asher (jerry@theashergroup.com)

} {

    refund_id:notnull
    order_id:notnull,naturalnum
    reason_for_return
    all_items_p:optional
    item_id:optional,multiple
    received_back_date:date,array
    received_back_time:time,array
}

ad_require_permission [ad_conn package_id] admin

set received_back_datetime $received_back_date(date)
if { [exists_and_not_null received_back_time(time)] } {
    append received_back_datetime " [ec_timeentrywidget_time_check \"$received_back_time(time)\"]$received_back_time(ampm)"
} else {
    append received_back_datetime " 12:00:00AM"
}


# the customer service rep must be logged on
set customer_service_rep [ad_get_user_id]

if {$customer_service_rep == 0} {
    set return_url "[ad_conn url]?[export_entire_form_as_url_vars]"
    ad_returnredirect "/register?[export_url_vars return_url]"
    return
}



# make sure they haven't already inserted this refund
if { [db_string get_refund_count "select count(*) from ec_refunds where refund_id=:refund_id"] > 0 } {
    ad_return_complaint 1 "<li>This refund has already been inserted into the database; it looks like you are using an old form.  <a href=\"one?[export_url_vars order_id]\">Return to the order.</a>"
    return
}

set exception_count 0
set exception_text ""

# they must have either checked "All items" and none of the rest, or
# at least one of the rest and not "All items"
# they also need to have shipment_date filled in

if { [info exists all_items_p] && [info exists item_id] } {
    incr exception_count
    append exception_text "<li>Please either check off \"All items\" or check off some of the items, but not both."
}
if { ![info exists all_items_p] && ![info exists item_id] } {
    incr exception_count
    append exception_text "<li>Please either check off \"All items\" or check off some of the items."
}

if { $exception_count > 0 } {
    ad_return_complaint 1 $exception_text
    return
}


append doc_body "[ad_admin_header "Specify refund amount"]

<h2>Specify refund amount</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index" "Orders"] [list "one?[export_url_vars order_id]" "One"] "Mark Items Returned"]

<hr>
"

set shipping_refund_percent [ad_parameter -package_id [ec_id] ShippingRefundPercent ecommerce]

if { ![info exists all_items_p] } {
    set item_id_list $item_id
    
    set sql "select i.item_id, p.product_name, i.price_charged, i.shipping_charged
    from ec_items i, ec_products p
    where i.product_id=p.product_id
    and i.item_id in ([join $item_id_list ", "])
    and i.item_state in ('shipped','arrived')"
    # the last line is for error checking (we don't want them to push "back" and 
    # try to do a refund again for the same items)
} else {
    set sql "select i.item_id, p.product_name, i.price_charged, i.shipping_charged
    from ec_items i, ec_products p
    where i.product_id=p.product_id
    and i.order_id=:order_id
    and i.item_state in ('shipped','arrived')"
}

# If they select "All items", I want to generate a list of the items because, regardless
# of what happens elsewhere on the site (e.g. an item is added to the order, thereby causing
# the query for all items to return one more item), I want only the items that they confirm
# here to be recorded as part of this return.
if { [info exists all_items_p] } {
    set item_id_list [list]
}

set items_to_print ""
db_foreach get_return_item_list $sql {
    
    if { [info exists all_items_p] } {
	lappend item_id_list $item_id
    }
    append items_to_print "<tr><td>$product_name</td><td><input type=text name=\"price_to_refund.${item_id}\" value=\"[format "%0.2f" $price_charged]\" size=4> (out of [ec_pretty_price $price_charged])</td><td><input type=text name=\"shipping_to_refund.${item_id}\" value=\"[format "%0.2f" [expr $shipping_charged * $shipping_refund_percent]]\" size=4> (out of [ec_pretty_price $shipping_charged])</td></tr>"
}

append doc_body "<form method=post action=items-return-3>
[export_form_vars refund_id order_id item_id_list received_back_datetime reason_for_return]
<blockquote>
<table border=0 cellspacing=0 cellpadding=10>
<tr><th>Item</th><th>Price to Refund</th><th>Shipping to Refund</th></tr>
$items_to_print
</table>
<p>
"

# we assume that, although only one refund may be done on an item, multiple refunds
# may be done on the base shipping cost, so we show them shipping_charged - shipping_refunded
set base_shipping [db_string unused "select nvl(shipping_charged,0) - nvl(shipping_refunded,0) from ec_orders where order_id=:order_id"]

append doc_body "Base shipping charge to refund:
<input type=text name=base_shipping_to_refund value=\"[format "%0.2f" [expr $base_shipping * $shipping_refund_percent]]\" size=4> (out of [ec_pretty_price $base_shipping])

<p>

</blockquote>

<center>
<input type=submit value=\"Continue\">
</center>

[ad_admin_footer]
"

doc_return  200 text/html $doc_body



