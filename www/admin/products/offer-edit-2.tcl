#  www/[ec_url_concat [ec_url] /admin]/products/offer-edit-2.tcl
ad_page_contract {
  Edit an offer.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  offer_id:integer,notnull
  product_id:integer,notnull
  retailer_id:integer,notnull
  price
  shipping
  stock_status
  old_retailer_id:integer,notnull
  offer_begins:array,date
  offer_ends:array,date
  special_offer_p
  special_offer_html:html
  shipping_unavailable_p:optional
}

ad_require_permission [ad_conn package_id] admin

set product_name [ec_product_name $product_id]

set exception_count 0
set exception_text ""

set possible_error_list [list [list retailer_id "to pick a retailer"] [list price "to enter the price"] [list special_offer_p "to specify whether this is a special offer"]]

foreach possible_error $possible_error_list {
    if { ![info exists [lindex $possible_error 0]] || [empty_string_p [set [lindex $possible_error 0]]] } {
	incr exception_count
	append exception_text "<li>You forgot [lindex $possible_error 1]."
    }
}

if { [regexp {[^0-9\.]} $price] } {
    incr exception_count
    append exception_text "<li>The price must be a number."
}

if { [regexp {[^0-9\.]} $shipping] } {
    incr exception_count
    append exception_text "<li>The shipping price must be a number."
}

# either there should be a shipping price or shipping_unavailable_p
# should exist (in which case it will be "t"), but not both
if { ![info exists shipping_unavailable_p] && [empty_string_p $shipping] } {
    incr exception_count
    append exception_text "<li>Please either enter a shipping cost or
    specify that only Pick Up is available.\n"
} elseif { [info exists shipping_unavailable_p] && ![empty_string_p $shipping] } {
    incr exception_count
    append exception_text "<li>You have specified that only Pick Up is available, therefore you must leave the shipping price blank.\n"
}

page_validation {
  # ec_date_widget_validate offer_begins
} {
  # ec_date_widget_validate offer_ends
}

set offer_begins_text [ec_date_text offer_begins]
set offer_ends_text [ec_date_text offer_ends]

unset offer_begins offer_ends

set offer_begins $offer_begins_text
set offer_ends $offer_ends_text

if { [info exists offer_begins] && [empty_string_p $offer_begins] } {
    incr exception_count
    append exception_text "<li>You forgot to enter the date that the offer begins.\n"
}

if { [info exists offer_ends] && [empty_string_p $offer_ends] } {
    incr exception_count
    append exception_text "<li>You forgot to enter the date that the offer expires.\n"
}

if { $exception_count > 0 } {
    ad_return_complaint $exception_count $exception_text
    return
}

# add some times to the dates, so that it starts at the beginning
# of the first day and ends at the end of the last day
set offer_begins "$offer_begins 00:00:00"
set offer_ends "$offer_ends 23:59:59"
set to_date_offer_begins "to_date(:offer_begins,'YYYY-MM-DD HH24:MI:SS')"
set to_date_offer_ends "to_date(:offer_ends,'YYYY-MM-DD HH24:MI:SS')"

# see if a non-deleted offer for this product and retailer whose
# dates of validity overlap this offer is already in ec_offers, in which
# case they can't add this new offer


#
if { [db_string duplicate_offer_select "select count(*) from ec_offers
where product_id=:product_id
and retailer_id=:retailer_id
and offer_id != :offer_id
and deleted_p='f'
and (($to_date_offer_begins >= offer_begins and $to_date_offer_begins <= offer_ends) or ($to_date_offer_ends >= offer_begins and $to_date_offer_ends <= offer_ends) or ($to_date_offer_begins <= offer_ends and $to_date_offer_ends >= offer_ends))
"] > 0 } {
    ad_return_complaint 1 "<li>You already have an offer from this retailer for this product whose dates overlap with the dates of this offer.  Please either delete the previous offer before editing this one, or edit the previous offer instead of editing this one.\n"

    return
}

doc_body_append "[ad_admin_header "Confirm Retailer Offer on $product_name"]

<h2>Confirm Retailer Offer on $product_name</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index.tcl" "Products"] [list "one.tcl?[export_url_vars product_id]" $product_name] "Confirm Retailer Offer"]

<hr>
"

set currency [ad_parameter -package_id [ec_id] Currency ecommerce]

doc_body_append "<table>
<tr>
<td>Retailer:</td>
<td>[db_string retailer_name_select "select retailer_name || ' (' || city || ', ' || usps_abbrev || ')' as retailer_name_to_print from ec_retailers where retailer_id=:retailer_id"]</td>
</tr>
<tr>
<td>Price:</td>
<td>[ec_pretty_price $price $currency]</td>
</tr>
<tr>
<td>Shipping:</td>
"
if { [info exists shipping_unavailable_p] } {
    doc_body_append "<td>Pick Up</td>\n"
} else {
    doc_body_append "<td>[ec_pretty_price $shipping $currency]</td>\n"
}

doc_body_append "</tr>
<tr>
<td>Stock Status:</td>
<td>
"    
if { ![empty_string_p $stock_status] } {
    doc_body_append [util_memoize "ad_parameter -package_id [ec_id] \"StockMessage[string toupper $stock_status]\"" [ec_cache_refresh]]
} else {
    doc_body_append [ec_message_if_null $stock_status]
}
doc_body_append "</td>
</tr>
<tr>
<td>Offer Begins</td>
<td>[util_AnsiDatetoPrettyDate $offer_begins]</td>
</tr>
<tr>
<td>Offer Expires</td>
<td>[util_AnsiDatetoPrettyDate $offer_ends]</td>
</tr>
"

if { $special_offer_p == "t" } {
    doc_body_append "<tr><td>Special Offer:</td><td>$special_offer_html</td></tr>\n"
}

doc_body_append "</table>

<form method=post action=offer-edit-3>
[export_form_vars offer_id product_id retailer_id price shipping stock_status old_retailer_id offer_begins offer_ends special_offer_p special_offer_html shipping_unavailable_p]
<center>
<input type=submit value=\"Confirm\">
</center>
</form>

[ad_admin_footer]
"
