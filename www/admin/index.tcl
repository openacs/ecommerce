# www/[ec_url_concat [ec_url] /admin]/index.tcl
ad_page_contract {
  Ecommerce administration index page.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
}

ad_require_permission [ad_conn package_id] admin

doc_body_append "[ad_admin_header "[ec_system_name] Administration"]

<h2>[ec_system_name] Administration</h2>
<table width=\"100%\">
  <tr>
   <td>[ad_context_bar Ecommerce([ec_system_name])]</td>
   <td align=\"right\">\[ <a href=\"/doc/ecommerce/\">help</a> \]</td>
  </tr>
</table>

<hr>
Documentation: <a href=\"/doc/ecommerce\">/doc/ecommerce</a> or <a href=\"[ec_url]doc/\">[ec_url]doc/</a>
<hr>
"

# get data for user class links
set user_classes_reqs_approval [ad_parameter -package_id [ec_id] UserClassAllowSelfPlacement ecommerce]
set n_not_yet_approved [db_string non_approved_users_select "select count(*) from ec_user_class_user_map where user_class_approved_p is null or user_class_approved_p='f'"]

doc_body_append "<h3>business operations</h3><ul>"

# orders

db_1row num_orders_select "
    select 
      sum(one_if_within_n_days(confirmed_date,1)) as n_in_last_24_hours,
      sum(one_if_within_n_days(confirmed_date,7)) as n_in_last_7_days
    from ec_orders_reportable"

db_1row num_products_select "select count(*) as n_products, round(avg(price),2) as avg_price from ec_products_displayable"

# links and info mainly related to business operations

doc_body_append "<li><a href=\"orders/\">Orders / Shipments / Refunds</a> <font size=-1>($n_in_last_24_hours orders in last 24 hours; $n_in_last_7_days in last 7 days)</font></li>"

# customer service

doc_body_append "<li><a href=\"customer-service/\">Customer Service</a> <font size=-1>([db_string open_issues_select "select count(*) from ec_customer_service_issues where close_date is null"] open issues)</font></li>"

# customer class membership requests
if { $user_classes_reqs_approval } {
    doc_body_append "<li><a href=\"user-classes/\">User Classes</a> <font size=-1>($n_not_yet_approved not yet approved user[ec_decode $n_not_yet_approved 1 "" "s"])</font></li>"
}

# customer reviews
if { [ad_parameter -package_id [ec_id] ProductCommentsAllowP ecommerce] } {
    doc_body_append "<li><a href=\"customer-reviews/\">Customer Reviews</a> <font size=-1>([db_string non_approved_comments_select "select count(*) from ec_product_comments where approved_p is null"] not yet approved)</font></li>"
}

# recommend products

doc_body_append "<li><a href=\"products/recommendations\">Recommend Products</a> <font size=-1>($n_products products; average price: [ec_pretty_price $avg_price])</font></li>"

doc_body_append "</ul>"

# links and info mainly related to website administration
doc_body_append "<h3>website administration</h3><ul>"

set unresolved_problem_count [db_string unresolved_problem_count_select "select count(*) from ec_problems_log where resolved_date is null"]

doc_body_append "<li><a href=\"problems/\">Potential Problems</a> <font size=-1>($unresolved_problem_count unresolved problem[ec_decode $unresolved_problem_count 1 "" "s"])</font></li>"

set paymentgateway_key [ad_parameter -package_id [ec_id] PaymentGateway ecommerce]
if { [string length $paymentgateway_key] > 1 } {
    doc_body_append "<li><a href=\"/$paymentgateway_key/admin\">Payment Gateway Administration</a></li>"
}


doc_body_append "<li><a href=\"products/\">Products</a> <font size=-1>($n_products products; average price: [ec_pretty_price $avg_price])</font></li>"

doc_body_append "<li><a href=\"templates/\">Product Templates</a></li>"

# customer class membership requests
if { !$user_classes_reqs_approval } {
    doc_body_append "<li><a href=\"user-classes/\">User Classes</a> <font size=-1>($n_not_yet_approved not yet approved user[ec_decode $n_not_yet_approved 1 "" "s"])</font></li>"
}

set multiple_retailers_p [ad_parameter -package_id [ec_id] MultipleRetailersPerProductP ecommerce]

if { $multiple_retailers_p } {
    doc_body_append "<li><a href=\"retailers/\">Retailers</a></li>"
} else {
    doc_body_append "<li><a href=\"shipping-costs/\">Shipping Costs</a></li>
    <li><a href=\"sales-tax/\">Sales Tax</a></li>"
}

doc_body_append "<li><a href=\"mailing-lists/\">Mailing Lists</a></li>
<li><a href=\"email-templates/\">Email Templates</a></li>
<li><a href=\"audit-tables\">Audit [ec_system_name]</a></li>"

doc_body_append "</ul>
[ad_admin_footer]
"
