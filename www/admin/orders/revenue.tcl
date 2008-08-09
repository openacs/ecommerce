ad_page_contract {

    Financial reports.

    @author Eve Andersson (eveander@arsdigita.com)
    @creation-date Summer 1999
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @revision-date March 2002

} {
}

ad_require_permission [ad_conn package_id] admin

doc_body_append "[ad_admin_header "Financial Reports"]

<h2>Financial Reports</h2>

[ad_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index" "Orders"] "Financial Reports"]

<hr>

<table border=0 cellspacing=0 cellpadding=10>
<tr><td><b>Period</b><td colspan=2><b>Revenue</b> <sup>1</sup></td></tr>
"

set revenue_sum 0
db_foreach reportable_transactions_select "select to_char(inserted_date,'YYYY') as transaction_year, to_char(inserted_date,'Q') as transaction_quarter, sum(decode(transaction_type,'charge',transaction_amount,-1*transaction_amount)) as revenue
from ec_fin_transactions_reportable
group by to_char(inserted_date,'YYYY'), to_char(inserted_date,'Q')
order by to_char(inserted_date,'YYYY') || to_char(inserted_date,'Q')" {
    set revenue_sum [expr $revenue_sum + $revenue]
    doc_body_append "<tr><td>$transaction_year Q$transaction_quarter<td align=right>[ec_pretty_pure_price $revenue]</td><td></td></tr>\n"
    if { $transaction_quarter == "4" } {
	doc_body_append "<tr><td>total for $transaction_year<td align=right><font size=+1 color=green>[ec_pretty_pure_price $revenue_sum]</td><td></td></tr>\n"
	set revenue_sum 0
    }
}

doc_body_append "<tr><td>&nbsp;</td><td></td><td></td></tr>

<tr><td><b>Period<td colspan=2><b>Product Sales</b> <sup>2</sup></tr>
"

# This slightly strange-looking query says:
# Give me the total price, shipping, and tax charged for the items in
# each shipment (that's what the view ec_items_money_view gives you).
# Then, if it's the first shipment in an order, add in the base shipping
# cost (and the tax on that shipping cost) for the order, because that's
# the time at which the base shipping is charged (that's what the two
# decodes give you).
# So now we're recognizing revenue at the time that the items are
# shipped, which is what we're supposed to do (read the ecommerce chapter
# of P & A's Guide to Web Publishing).
# Then, group this stuff by year & quarter for display purposes.

set price_sum 0
set shipping_sum 0
set tax_sum 0

db_foreach money_select "select to_char(shipment_date,'YYYY') as shipment_year,
to_char(shipment_date,'Q') as shipment_quarter,
nvl(sum(bal_price_charged),0) as total_price_charged,
nvl(sum(bal_shipping_charged + decode(mv.shipment_id,(select min(s2.shipment_id) from ec_shipments s2 where s2.order_id=mv.order_id),(select nvl(o.shipping_charged,0)-nvl(o.shipping_refunded,0) from ec_orders o where o.order_id=mv.order_id),0)),0) as total_shipping_charged,
nvl(sum(bal_tax_charged + decode(mv.shipment_id,(select min(s2.shipment_id) from ec_shipments s2 where s2.order_id=mv.order_id),(select nvl(o.shipping_tax_charged,0)-nvl(o.shipping_tax_refunded,0) from ec_orders o where o.order_id=mv.order_id),0)),0) as total_tax_charged
from ec_items_money_view mv
group by to_char(shipment_date,'YYYY'), to_char(shipment_date,'Q')
order by to_char(shipment_date,'YYYY') || to_char(shipment_date,'Q')" {
    set price_sum [expr $price_sum + $total_price_charged]
    set shipping_sum [expr $shipping_sum + $total_shipping_charged]
    set tax_sum [expr $tax_sum + $total_tax_charged]
    doc_body_append "<tr><td>$transaction_year Q$transaction_quarter<td align=right>Price: [ec_pretty_pure_price $total_price_charged] | Shipping: [ec_pretty_pure_price $total_shipping_charged] | Tax [ec_pretty_pure_price $total_tax_charged]</td><td></td></tr>\n"
    if { $transaction_quarter == "4" } {
	doc_body_append "<tr><td>total for $transaction_year<td align=right><font size=+1 color=green>Price: [ec_pretty_pure_price $price_sum] | Shipping [ec_pretty_pure_price $shipping_sum] | Tax [ec_pretty_pure_price $tax_sum]</td><td></td></tr>\n"
	set price_sum 0
	set shipping_sum 0
	set tax_sum 0
    }
}

doc_body_append "<tr><td>&nbsp;</td><td></td><td></td></tr>

<tr><td><b>Period<td colspan=2><b>Gift Certificate Sales</b> <sup>3</sup></tr>
"

set amount_sum 0

db_foreach gift_certificates_select "select to_char(issue_date,'YYYY') as issue_year,
to_char(issue_date,'Q') as issue_quarter,
nvl(sum(amount),0) as amount
from ec_gift_certificates where gift_certificate_state = 'authorized'
group by to_char(issue_date,'YYYY'), to_char(issue_date,'Q')
order by to_char(issue_date,'YYYY') || to_char(issue_date,'Q')" {
    set amount_sum [expr $amount_sum + $amount]
    doc_body_append "<tr><td>$issue_year Q$issue_quarter<td align=right>[ec_pretty_pure_price $amount]</td><td></td></tr>\n"
    if { $issue_quarter == "4" } {
	doc_body_append "<tr><td>total for $issue_year<td align=right><font size=+1 color=green>[ec_pretty_pure_price $amount_sum]</td><td></td></tr>\n"
	set amount_sum 0
    }
}

doc_body_append "<tr><td>&nbsp;</td><td></td><td></td></tr>

<tr><td><b>Period<td colspan=2><b>Gift Certificates Issued</b> <sup>4</sup></td></tr>
"

set amount_sum 0

db_foreach gift_certificates_select "select to_char(issue_date,'YYYY') as issue_year,
to_char(issue_date,'Q') as issue_quarter,
nvl(sum(amount),0) as amount
from ec_gift_certificates where gift_certificate_state = 'authorized'
group by to_char(issue_date,'YYYY'), to_char(issue_date,'Q')
order by to_char(issue_date,'YYYY') || to_char(issue_date,'Q')" {
    set amount_sum [expr $amount_sum + $amount]
    doc_body_append "<tr><td>$issue_year Q$issue_quarter<td align=right>[ec_pretty_pure_price $amount]</td><td></td></tr>\n"
    if { $issue_quarter == "4" } {
	doc_body_append "<tr><td>total for $issue_year<td align=right><font size=+1 color=green>[ec_pretty_pure_price $amount_sum]</td><td></td></tr>\n"
	set amount_sum 0
    }
}

doc_body_append "<tr><td>&nbsp;</td><td></td><td></td></tr>

<tr><td><b>Expires<td colspan=2><b>Gift Certificates Outstanding</b> <sup>5</sup></tr>
"

# Even if a gift certificate is tied to items that have been ordered, it is still
# considered outstanding until it is actually applied to shipped items.

# The "untied" amount is equal to the remaining amount of each gift certificate.
# The "tied but not officially used" amount is equal to the amount tied to an
# order minus the total cost of the part of the order that has already shipped.
# The "outstanding" amount is the sum of these two.
# The thing that makes this complicated is that gift certificates aren't tied
# to certain parts of an order (the shipped part vs. the unshipped part), so we
# have to take the latest-expiring part to be the "not officially used" part
# (since that's the part that would be reinstated if part of the order were
# unable to be shipped)

set amount_outstanding_sum 0

db_foreach gift_certificates_approved_select "select to_char(expires,'YYYY') as expires_year,
to_char(expires,'Q') as expires_quarter,
nvl(sum(gift_certificate_amount_left(gift_certificate_id)),0) + nvl(sum(ec_gift_cert_unshipped_amount(gift_certificate_id)),0) as amount_outstanding
from ec_gift_certificates_approved
group by to_char(expires,'YYYY'), to_char(expires,'Q')
order by to_char(expires,'YYYY') || to_char(expires,'Q')" {
    set amount_outstanding_sum [expr $amount_outstanding_sum + $amount_outstanding]
    doc_body_append "<tr><td>$expires_year Q$expires_quarter<td align=right>[ec_pretty_pure_price $amount_outstanding]</td><td></td></tr>\n"
    if { $expires_quarter == "4" } {
	doc_body_append "<tr><td>total for $expires_year<td align=right><font size=+1 color=green>[ec_pretty_pure_price $amount_outstanding_sum]</td><td></td></tr>\n"
	set amount_sum 0
    }
}

doc_body_append "</table>

<p>
<br>
<sup>1</sup> <b>Revenue</b>: the actual amount of credit card charges minus the amount of credit card refunds.
<p>
<sup>2</sup> <b>Sales</b>: the price charged, the shipping charged, and the tax charged (minus the amounts refunded) for shipped items (most companies recognize revenue when items are shipped so that they don't risk double counting an account receivable and an item in inventory; see the <a href=\"http://www.arsdigita.com/books/panda/ecommerce.html\">ecommerce chapter of Philip &amp; Alex's Guide to Web Publishing</a>).  Note that this is different from revenue because revenue includes sales of gift certificates.  Additionally, some products were paid for using gift certificates.
<p>
<sup>3</sup> <b>Gift Certificate Sales</b>: the amount of gift certificates purchased (recognized on date of purchase).
<p>
<sup>4</sup> <b>Gift Certificates Issued</b>: the amount of gift certificates issued to customers free of charge by web site administrators.
<p>
<sup>5</sup> <b>Gift Certificates Outstanding</b>: gift certificates which have not yet been applied to shipped items (therefore they are 
														       considered a liability).
[ad_admin_footer]
"
