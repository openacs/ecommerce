# /www/[ec_url_concat [ec_url] /admin]/orders/fulfill-2.tcl
ad_page_contract {
  This script shows confirmation page & shipping address.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id fulfill-2.tcl,v 3.5.2.6 2000/09/22 01:34:57 kevin Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  order_id:integer,notnull
  all_items_p:optional
  item_id:multiple,optional,integer
  shipment_date:array,date
  shipment_time:array,time
  expected_arrival_date:optional,array,date
  expected_arrival_time:optional,array,time
    {carrier ""}
    {carrier_other ""}
    {tracking_number ""}
}

ns_set print [ns_getform]

ad_require_permission [ad_conn package_id] admin

# order_id, shipment_date (in pieces),
# either all_items_p or a series of item_ids

# if it's a shippable order: expected_arrival_date (in pieces),
# carrier, carrier_other, tracking_number,

# the customer service rep must be logged on

ad_maybe_redirect_for_registration
set customer_service_rep [ad_get_user_id]

if { ![empty_string_p $carrier_other] } {
    set carrier $carrier_other
}

set temp_shipment_date $shipment_date(date)
if { [exists_and_not_null shipment_time(time)] } {
    set shipment_time(time) [ec_timeentrywidget_time_check $shipment_time(time)]
    append temp_shipment_date " $shipment_time(time)$shipment_time(ampm)"
} else {
    append temp_shipment_date " 12:00:00AM"
}

set temp_expected_arrival_date ""
if { [exists_and_not_null expected_arrival_date(date)] } {
    append temp_expected_arrival_date $expected_arrival_date(date)
    if { [exists_and_not_null expected_arrival_time(time)] } {
        set expected_arrival_time(time) [ec_timeentrywidget_time_check $expected_arrival_time(time)]
	append temp_expected_arrival_date " $expected_arrival_time(time)$expected_arrival_time(ampm)"
    } else {
	append temp_expected_arrival_date " 12:00:00AM"
    }
}


set shippable_p [ec_decode [db_string shipping_method_select "
select shipping_method
  from ec_orders
 where order_id=:order_id
"] "no shipping" 0 1]

if { $shippable_p } {

    if { ![empty_string_p $carrier_other] } {
        set carrier $carrier_other
    }
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


append page_html "[ad_admin_header "Confirm that these item(s) have been [ec_decode $shippable_p 1 "shipped" "fulfilled"]"]

<h2>Confirm that these item(s) have been [ec_decode $shippable_p 1 "shipped" "fulfilled"]</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index" "Orders"] [list "fulfillment" "Fulfillment"] "One Order"]

<hr>
"

set shipment_id [db_string get_new_ship_seq "select ec_shipment_id_sequence.nextval from dual"]

if { [info exists item_id] && ![empty_string_p item_id] } {
    set sql  "select i.item_id, p.product_name, p.one_line_description, p.product_id, i.price_charged, i.price_name, i.color_choice, i.size_choice, i.style_choice
    from ec_items i, ec_products p
    where i.product_id=p.product_id
    and i.item_id in ([join $item_id ", "])"
} else {
    set sql "select i.item_id, p.product_name, p.one_line_description, p.product_id, i.price_charged, i.price_name, i.color_choice, i.size_choice, i.style_choice
    from ec_items i, ec_products p
    where i.product_id=p.product_id
    and i.order_id=:order_id
    and i.item_state='to_be_shipped'"
}

# If they select "All items", I want to generate a list of the items because, regardless
# of what happens elsewhere on the site (e.g. an item is added to the order, thereby causing
# the query for all items to return one more item), I want only the items that they confirm
# here to be recorded as part of this shipment.
if { [info exists all_items_p] } {
    set item_id_list [list]
}

set items_to_print ""
db_foreach get_items_to_ship $sql {

    if { [info exists all_items_p] } {
	lappend item_id_list $item_id
    }

    set option_list [list]
    if { ![empty_string_p $color_choice] } {
	lappend option_list "Color: $color_choice"
    }
    if { ![empty_string_p $size_choice] } {
	lappend option_list "Size: $size_choice"
    }
    if { ![empty_string_p $style_choice] } {
	lappend option_list "Style: $style_choice"
    }
    set options [join $option_list ", "]

   append items_to_print "<li> $product_name; [ec_decode $options "" "" "$options; "]$price_name: [ec_pretty_price $price_charged]"
}

if { [info exists all_items_p] } {
    set item_id $item_id_list
}

append page_html "<form method=post action=fulfill-3>
[export_form_vars shipment_id order_id item_id carrier tracking_number]
<input type=hidden name=shipment_date value=\"$temp_shipment_date\">
<input type=hidden name=expected_arrival_date value=\"$temp_expected_arrival_date\">

<center>
<input type=submit value=\"Confirm\">
</center>
<blockquote>
Item(s):
<ul>
$items_to_print
</ul>
"

if { !$shippable_p } {
    append page_html "Pickup date: [ec_formatted_date $temp_shipment_date]"
} else {
    append page_html "Shipment information:

<ul>

<li>Shipment date: [ec_formatted_date $temp_shipment_date]

[ec_decode $temp_expected_arrival_date "" "" "<li>Expected arrival date: [ec_formatted_date $temp_expected_arrival_date]"]

[ec_decode $carrier "" "" "<li>Carrier: $carrier"]

[ec_decode $tracking_number "" "" "<li>Tracking Number: $tracking_number"]

</ul>

Ship to:
<br>

<blockquote>

[ec_display_as_html [ec_pretty_mailing_address_from_ec_addresses [db_string get_pretty_mailing_address "select shipping_address from ec_orders where order_id=:order_id"]]]

</blockquote>
"
}

append page_html "
</blockquote>

<center>
<input type=submit value=\"Confirm\">
</center>
</form>

[ad_admin_footer]
"
db_release_unused_handles

doc_return 200 text/html $page_html


