# /www/[ec_url_concat [ec_url] /admin]/orders/index.tcl
ad_page_contract {

  The main page for the orders section of the ecommerce admin pages.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id index.tcl,v 3.2.2.3 2000/08/16 21:19:21 seb Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
}

ad_require_permission [ad_conn package_id] admin

doc_body_append "[ad_admin_header "Orders / Shipments / Refunds"]

<h2>Orders / Shipments / Refunds</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] "Orders / Shipments / Refunds"]

<hr>
"



doc_body_append "<ul>"

db_1row recent_orders_select "
select 
  sum(one_if_within_n_days(confirmed_date,1)) as n_o_in_last_24_hours,
  sum(one_if_within_n_days(confirmed_date,7)) as n_o_in_last_7_days
from ec_orders_reportable
"

db_1row recent_gift_certificates_purchased_select "
select
  sum(one_if_within_n_days(issue_date,1)) as n_g_in_last_24_hours,
  sum(one_if_within_n_days(issue_date,7)) as n_g_in_last_7_days
from ec_gift_certificates_purchased
"

db_1row recent_gift_certificates_issued_select "
select
  sum(one_if_within_n_days(issue_date,1)) as n_gi_in_last_24_hours,
  sum(one_if_within_n_days(issue_date,7)) as n_gi_in_last_7_days
from ec_gift_certificates_issued
"

db_1row recent_shipments_select "
select
  sum(one_if_within_n_days(shipment_date,1)) as n_s_in_last_24_hours,
  sum(one_if_within_n_days(shipment_date,7)) as n_s_in_last_7_days
from ec_shipments
"

db_1row recent_refunds_select "
select
  sum(one_if_within_n_days(refund_date,1)) as n_r_in_last_24_hours,
  sum(one_if_within_n_days(refund_date,7)) as n_r_in_last_7_days
from ec_refunds
"

set n_standard_to_ship [db_string unused "select count(*) from ec_orders_shippable where shipping_method='standard'"]
set n_express_to_ship [db_string unused "select count(*) from ec_orders_shippable where shipping_method='express'"]

doc_body_append "
<li><a href=\"by-order-state-and-time\">Orders</a> <font size=-1>($n_o_in_last_24_hours in last 24 hours; $n_o_in_last_7_days in last 7 days)</font>
<p>
<li><a href=\"fulfillment\">Order Fulfillment</a> <font size=-1>($n_standard_to_ship order[ec_decode $n_standard_to_ship 1 "" "s"] to be shipped via standard shipping[ec_decode $n_express_to_ship "0" "" ", $n_express_to_ship via express shipping"])</font>
<p>
<li><a href=\"gift-certificates\">Gift Certificate Purchases</a> <font size=-1>($n_g_in_last_24_hours in last 24 hours; $n_g_in_last_7_days in last 7 days)</font>
<p>
<li><a href=\"gift-certificates-issued\">Gift Certificates Issued</a> <font size=-1>($n_gi_in_last_24_hours in last 24 hours; $n_gi_in_last_7_days in last 7 days)</font>
<p>
<li><a href=\"shipments\">Shipments</a> <font size=-1>($n_s_in_last_24_hours in last 24 hours; $n_s_in_last_7_days in last 7 days)</font>
<p>
<li><a href=\"refunds\">Refunds</a> <font size=-1>($n_r_in_last_24_hours in last 24 hours; $n_r_in_last_7_days in last 7 days)</font>
<p>
<li><a href=\"revenue\">Financial Reports</a>
<p>
<li>Search for an order:
<blockquote>

<form method=post action=search>
By Order ID: <input type=text name=order_id_query_string size=10>
</form>

<form method=post action=search>
By Product Name: <input type=text name=product_name_query_string size=10>
</form>

<form method=post action=search>
By Customer Last Name: <input type=text name=customer_last_name_query_string size=10>
</form>

</blockquote>
</ul>
[ad_admin_footer]
"
