ad_page_contract {

    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @revision-date April 2002

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

# The customer service rep must be logged on

set customer_service_rep [ad_get_user_id]
if {$customer_service_rep == 0} {
    set return_url "[ad_conn url]?[export_entire_form_as_url_vars]"
    ad_returnredirect "/register?[export_url_vars return_url]"
    ad_script_abort
}

# Make sure they haven't already inserted this refund

if { [db_string get_refund_count "
    select count(*) 
    from ec_refunds 
    where refund_id=:refund_id"] > 0 } {
    ad_return_complaint 1 "
	<li>This refund has already been inserted into the database. Are you using an old form? <a href=\"one?[export_url_vars order_id]\">Return to the order.</a>"
    ad_script_abort
}

set exception_count 0
set exception_text ""

# They must have either checked "All items" and none of the rest, or
# at least one of the rest and not "All items". They also need to have
# shipment_date filled in

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
    ad_script_abort
}

append doc_body "
    [ad_admin_header "Specify refund amount"]

    <h2>Specify refund amount</h2>

    [ad_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index" "Orders"] [list "one?[export_url_vars order_id]" "One"] "Mark Items Returned"]
    <hr>"

set shipping_refund_percent [ad_parameter -package_id [ec_id] ShippingRefundPercent ecommerce]

if { ![info exists all_items_p] } {
    set item_id_list $item_id
    set sql [db_map all_items_select]
} else {
    set sql [db_map selected_items_select] 
}

# Generate a list of the items if they selected "All items" because,
# regardless of what happens elsewhere on the site (e.g. an item is
# added to the order, thereby causing the query for all items to
# return one more item), only the items that they confirm here should
# be recorded as part of this return.

if { [info exists all_items_p] } {
    set item_id_list [list]
}

set items_to_print ""
db_foreach get_return_item_list $sql {
    
    if { [info exists all_items_p] } {
	lappend item_id_list $item_id
    }
    append items_to_print "
	<tr>
	  <td>$product_name</td>
	   <td><input type=text name=\"price_to_refund.${item_id}\" value=\"[format "%0.2f" $price_charged]\" size=\"5\"> (out of [ec_pretty_price $price_charged])</td>
 	   <td><input type=text name=\"shipping_to_refund.${item_id}\" value=\"[format "%0.2f" [expr $shipping_charged * $shipping_refund_percent]]\" size=\"5\"> 
	       (out of [ec_pretty_price $shipping_charged])</td>
	</tr>"
}

append doc_body "
    <form method=post action=items-return-3>
      [export_form_vars refund_id order_id item_id_list received_back_datetime reason_for_return]
      <blockquote>
        <table border=0 cellspacing=0 cellpadding=10>
          <tr>
            <th>Item</th><th>Price to Refund</th><th>Shipping to Refund</th>
         </tr>
         $items_to_print
       </table>"

# Although only one refund may be done on an item, multiple refunds
# may be done on the base shipping cost, so show shipping_charged -
# shipping_refunded.

set base_shipping [db_string base_shipping_select "
    select nvl(shipping_charged,0) - nvl(shipping_refunded,0) 
    from ec_orders 
    where order_id=:order_id"]

append doc_body "
      <p>Base shipping charge to refund: 
      <input type=text name=base_shipping_to_refund value=\"[format "%0.2f" [expr $base_shipping * $shipping_refund_percent]]\" size=\"5\"> 
      (out of [ec_pretty_price $base_shipping])</p>
    </blockquote>

    <center><input type=submit value=\"Continue\"></center>

    [ad_admin_footer]"

doc_return  200 text/html $doc_body
