# /www/[ec_url_concat [ec_url] /admin]/orders/items-return-3.tcl
ad_page_contract {

    @param refund_id
    @param order_id
    @param received_back_date
    @param reason_for_return
    @param item_id_list 
    @param price_to_refund(item_id) for each item_id,
    @param shipping_to_refund(item_id) for each item_id, 
    @param base_shipping_to_refund

    @author
    @creation-date
    @cvs-id items-return-3.tcl,v 3.2.6.7 2000/09/22 01:34:57 kevin Exp
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    refund_id:notnull,naturalnum
    order_id:notnull,naturalnum
    received_back_datetime
    reason_for_return
    item_id_list
    price_to_refund:array
    shipping_to_refund:array
    base_shipping_to_refund
}

ad_require_permission [ad_conn package_id] admin

# the customer service rep must be logged on
set customer_service_rep [ad_get_user_id]

if {$customer_service_rep == 0} {
    set return_url "[ad_conn url]?[export_entire_form_as_url_vars]"
    ad_returnredirect "/register?[export_url_vars return_url]"
    return
}

# error checking:
# make sure price_to_refund($item_id) is <= price_charged for that item
# same with shipping
# make sure base_shipping_to_refund is <= base shipping charged - refunded


# make sure they haven't already inserted this refund
if { [db_string get_count_refunds "select count(*) from ec_refunds where refund_id=:refund_id"] > 0 } {
    ad_return_complaint 1 "<li>This refund has already been inserted into the database; it looks like you are using an old form.  <a href=\"one?[export_url_vars order_id]\">Return to the order.</a>"
    return
}

set exception_count 0
set exception_text ""

set sql "select i.item_id, p.product_name, nvl(i.price_charged,0) as price_charged, nvl(i.shipping_charged,0) as shipping_charged, nvl(i.price_tax_charged,0) as price_tax_charged, nvl(i.shipping_tax_charged,0) as shipping_tax_charged
from ec_items i, ec_products p
where i.product_id=p.product_id
and i.item_id in ([join $item_id_list ", "])"

# add up the items' price/shipping/tax to refund as we go
set total_price_to_refund 0
set total_shipping_to_refund 0
set total_price_tax_to_refund 0
set total_shipping_tax_to_refund 0

db_foreach get_items_for_return $sql {
    
    if { [empty_string_p $price_to_refund($item_id)] } {
	incr exception_count
	append exception_text "<li>Please enter a price to refund for $product_name."
    } elseif {[regexp {[^0-9\.]} $price_to_refund($item_id)]} {
	incr exception_count
	append exception_text "<li>Please enter a purely numeric price to refund for $product_name (no letters or special characters)."
    } elseif { $price_to_refund($item_id) > $price_charged } {
	incr exception_count
	append exception_text "<li>Please enter a price to refund for $product_name that is less than or equal to [ec_pretty_price $price_charged]."
    } else {
	set total_price_to_refund [expr $total_price_to_refund + $price_to_refund($item_id)]
	# tax will be the minimum of the tax actually charged and the tax that would have been charged on the price to refund
	# (tax rates may have changed in the meantime and we don't want to refund more than they paid)
	set tax_price_to_refund $price_to_refund($item_id)

	set iteration_price_tax_to_refund [ec_min $price_tax_charged [db_string get_ec_tax "select ec_tax(:tax_price_to_refund,0,:order_id) from dual"]]
	set total_price_tax_to_refund [expr $total_price_tax_to_refund + $iteration_price_tax_to_refund]
    }

    if { [empty_string_p $shipping_to_refund($item_id)] } {
	incr exception_count
	append exception_text "<li>Please enter a shipping amount to refund for $product_name."
    } elseif {[regexp {[^0-9\.]} $shipping_to_refund($item_id)]} {
	incr exception_count
	append exception_text "<li>Please enter a purely numeric shipping amount to refund for $product_name (no letters or special characters)."
    } elseif { $shipping_to_refund($item_id) > $shipping_charged } {
	incr exception_count
	append exception_text "<li>Please enter a shipping amount to refund for $product_name that is less than or equal to [ec_pretty_price $shipping_charged]."
    } else {
	set total_shipping_to_refund [expr $total_shipping_to_refund + $shipping_to_refund($item_id)]

	set iteration_shipping_tax_to_refund [ec_min $shipping_tax_charged [db_string get_it_shipping_tax_refund "select ec_tax(0,$shipping_to_refund($item_id),$order_id) from dual"]]
	set total_shipping_tax_to_refund [expr $total_shipping_tax_to_refund + $iteration_shipping_tax_to_refund]
    }
}

db_1row get_shipping_charged_values "select nvl(shipping_charged,0) - nvl(shipping_refunded,0) as base_shipping, nvl(shipping_tax_charged,0) - nvl(shipping_tax_refunded,0) as base_shipping_tax from ec_orders where order_id=:order_id"


if { [empty_string_p $base_shipping_to_refund] } {
    incr exception_count
    append exception_text "<li>Please enter a base shipping amount to refund."
} elseif {[regexp {[^0-9\.]} $base_shipping_to_refund]} {
    incr exception_count
    append exception_text "<li>Please enter a purely numeric base shipping amount to refund (no letters or special characters)."
} elseif { $base_shipping_to_refund > $base_shipping } {
    incr exception_count
    append exception_text "<li>Please enter a base shipping amount to refund that is less than or equal to [ec_pretty_price $base_shipping]."
} else {
    set total_shipping_to_refund [expr $total_shipping_to_refund + $base_shipping_to_refund]

    set iteration_shipping_tax_to_refund [ec_min $base_shipping_tax [db_string get_base_shipping_it_refund "select ec_tax(0,:base_shipping,:order_id) from dual"]]
    set total_shipping_tax_to_refund [expr $total_shipping_tax_to_refund + $iteration_shipping_tax_to_refund]

}

if { $exception_count > 0 } {
    ad_return_complaint $exception_count $exception_text
    return
}

set total_tax_to_refund [expr $total_price_tax_to_refund + $total_shipping_tax_to_refund]
set total_amount_to_refund [expr $total_price_to_refund + $total_shipping_to_refund + $total_tax_to_refund]

# determine how much of this will be refunded in cash
set cash_amount_to_refund [db_string get_cash_refunded "select ec_cash_amount_to_refund(:total_amount_to_refund,:order_id) from dual"]

# calculate gift certificate amount and tax to refund
set certificate_amount_to_reinstate [expr $total_amount_to_refund - $cash_amount_to_refund]
if { $certificate_amount_to_reinstate < 0 } {
    # because of rounding
    set certificate_amount_to_reinstate 0
}

# see if the credit card data is still in the database (otherwise they'll have to type in the query password)
set creditcard_number [db_string get_cc_number "select creditcard_number from ec_orders o, ec_creditcards c where o.creditcard_id=c.creditcard_id and o.order_id=:order_id" -default ""]


append doc_body "[ad_admin_header "Refund Totals"]

<h2>Refund Totals</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index" "Orders"] [list "one?[export_url_vars order_id]" "One"] "Refund Totals"]

<hr>
<form method=post action=items-return-4>
[export_entire_form]
[export_form_vars cash_amount_to_refund certificate_amount_to_reinstate]
<blockquote>
Total refund amount: [ec_pretty_price $total_amount_to_refund] (price: [ec_pretty_price $total_price_to_refund], shipping: [ec_pretty_price $total_shipping_to_refund], tax: [ec_pretty_price $total_tax_to_refund])
<p>
<ul>
<li>[ec_pretty_price $certificate_amount_to_reinstate] will be reinstated in gift certificates.<br>
<li>[ec_pretty_price $cash_amount_to_refund] will be refunded to the customer's credit card.<br>
</ul>
"

# have them type in the query password
if { [empty_string_p $creditcard_number] && $cash_amount_to_refund > 0 } {
    append doc_body "<br>
    Enter either your CyberCash card-query password (which we can use to try to obtain
    the credit card number used on this order) or enter a new credit card:
    <blockquote>
    <table border=0 cellspacing=0 cellpadding=10>
    <tr><td><input type=radio name=card_query_p value=t checked>Password for card-query:</td>
    <td><input type=text size=30 name=card_query_password></td></tr>
    <tr><td valign=top><input type=radio name=card_query_p value=f>New Credit Card:
    <b>not yet functional</b></td>
    <td>
       <table>
       <tr>
       <td>Credit card number:</td>
       <td><input type=text name=creditcard_number size=17></td>
       </tr>
       <tr>
       <td>Type:</td>
       <td>[ec_creditcard_widget]</td>
       </tr>
       <tr>
       <td>Expires:</td>
       <td>[ec_creditcard_expire_1_widget] [ec_creditcard_expire_2_widget]</td>
       <tr>
       <td>Billing zip code:</td>
       <td><input type=text name=billing_zip_code value=\"[db_string get_zip_code "select zip_code from ec_orders o, ec_addresses a where o.shipping_address=a.address_id and o.order_id=:order_id"]\" size=5></td>
       </tr>
       </table>
    </td></tr>
    </table>
    </blockquote>
    "
}

append doc_body "<br>
</blockquote>
<center>
<input type=submit value=\"Complete the Refund\">
</center>
</form>
[ad_admin_footer]
"




doc_return  200 text/html $doc_body



