ad_page_contract {

    The main page for the orders section of the ecommerce admin pages.

    @author Eve Andersson (eveander@arsdigita.com)
    @creation-date Summer 1999
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @revision-date April 2002

} {
}

ad_require_permission [ad_conn package_id] admin

doc_body_append "
    [ad_admin_header "Orders / Shipments / Refunds"]
    
    <h2>Orders / Shipments / Refunds</h2>

    [ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] "Orders / Shipments / Refunds"]

    <hr>"

db_1row recent_orders_select "
    select sum(one_if_within_n_days(confirmed_date,1)) as n_o_in_last_24_hours, sum(one_if_within_n_days(confirmed_date,7)) as n_o_in_last_7_days
    from ec_orders_reportable"

db_1row recent_gift_certificates_purchased_select "
    select sum(one_if_within_n_days(issue_date,1)) as n_g_in_last_24_hours, sum(one_if_within_n_days(issue_date,7)) as n_g_in_last_7_days
    from ec_gift_certificates_purchased"

db_1row recent_gift_certificates_issued_select "
    select sum(one_if_within_n_days(issue_date,1)) as n_gi_in_last_24_hours, sum(one_if_within_n_days(issue_date,7)) as n_gi_in_last_7_days
    from ec_gift_certificates_issued"

db_1row recent_shipments_select "
    select sum(one_if_within_n_days(shipment_date,1)) as n_s_in_last_24_hours, sum(one_if_within_n_days(shipment_date,7)) as n_s_in_last_7_days
    from ec_shipments"

db_1row recent_refunds_select "
    select sum(one_if_within_n_days(refund_date,1)) as n_r_in_last_24_hours, sum(one_if_within_n_days(refund_date,7)) as n_r_in_last_7_days
    from ec_refunds"

doc_body_append "
    <ul>
      <li><p><a href=\"by-order-state-and-time\">Orders</a> 
        <font size=-1>($n_o_in_last_24_hours in last 24 hours; $n_o_in_last_7_days in last 7 days)</font></p></li>
      <li><p><a href=\"fulfillment\">Order Fulfillment</a> 
        <font size=-1>"

set count 0
db_foreach shipping_method_counts "
    select shipping_method, coalesce(count(*), 0) as shipping_method_count
    from ec_orders_shippable
    where shipping_method not in ('no_shipping', 'pickup')
    and shipping_method is not null
    group by shipping_method" {

    incr count
    if {$count == 1} {
	doc_body_append "("
    }
    doc_body_append "$shipping_method_count to be shipped via $shipping_method"
    if {$count < [db_resultrows]} {
	doc_body_append ", "
    } else {
	doc_body_append ")"
    }
}

doc_body_append "</font></p></li>
      <li><p><a href=\"gift-certificates\">Gift Certificate Purchases</a> 
        <font size=-1>($n_g_in_last_24_hours in last 24 hours; $n_g_in_last_7_days in last 7 days)</font></p></li>
      <li><p><a href=\"gift-certificates-issued\">Gift Certificates Issued</a> 
        <font size=-1>($n_gi_in_last_24_hours in last 24 hours; $n_gi_in_last_7_days in last 7 days)</font></p></li>
      <li><p><a href=\"shipments\">Shipments</a> 
       <font size=-1>($n_s_in_last_24_hours in last 24 hours; $n_s_in_last_7_days in last 7 days)</font></p></li>
      <li><p><a href=\"refunds\">Refunds</a> 
        <font size=-1>($n_r_in_last_24_hours in last 24 hours; $n_r_in_last_7_days in last 7 days)</font></p></li>
      <li><p><a href=\"revenue\">Financial Reports</a>
      <li><p>Search for an order:</p>
        <blockquote>
          <form method=post action=search>
            <p>By Order ID: <input type=text name=order_id_query_string size=10></p>
          </form>
          <form method=post action=search>
            <p>By Product SKU: <input type=text name=product_sku_query_string size=10></p>
          </form>
          <form method=post action=search>
            <p>By Product Name: <input type=text name=product_name_query_string size=10></p>
          </form>
          <form method=post action=search>
            <p>By Customer Last Name: <input type=text name=customer_last_name_query_string size=10></p>
          </form>
        </blockquote>
      </li>
    </ul>
    [ad_admin_footer]"
