# www/[ec_url_concat [ec_url] /admin]/index.tcl
ad_page_contract {
  Ecommerce administration index page.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id index.tcl,v 3.2.2.2 2000/07/22 07:57:30 ron Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
}

ad_require_permission [ad_conn package_id] admin

doc_body_append "[ad_admin_header "[ec_system_name] Administration"]

<h2>[ec_system_name] Administration</h2>

[ad_admin_context_bar Ecommerce([ec_system_name])]

<hr>
Documentation: <a href=\"/doc/ecommerce\">/doc/ecommerce</a> or <a href=\"[ec_url]doc/\">[ec_url]doc/</a>

<ul>

"



# Problems

set unresolved_problem_count [db_string unresolved_problem_count_select "select count(*) from ec_problems_log where resolved_date is null"]

doc_body_append "

<li><a href=\"problems/\">Potential Problems</a> <font size=-1>($unresolved_problem_count unresolved problem[ec_decode $unresolved_problem_count 1 "" "s"])</font>
    <p>
"

db_1row num_orders_select "
select 
  sum(one_if_within_n_days(confirmed_date,1)) as n_in_last_24_hours,
  sum(one_if_within_n_days(confirmed_date,7)) as n_in_last_7_days
from ec_orders_reportable"

db_1row num_products_select "select count(*) as n_products, round(avg(price),2) as avg_price from ec_products_displayable"

doc_body_append "

<li><a href=\"orders/\">Orders / Shipments / Refunds</a> <font size=-1>($n_in_last_24_hours orders in last 24 hours; $n_in_last_7_days in last 7 days)</font>

<P>

<li><a href=\"products/\">Products</a> <font size=-1>($n_products products; average price: [ec_pretty_price $avg_price])</font>

<p>
<li><a href=\"customer-service/\">Customer Service</a> <font size=-1>([db_string open_issues_select "select count(*) from ec_customer_service_issues where close_date is null"] open issues)</font>
<p>
"

if { [ad_parameter -package_id [ec_id] ProductCommentsAllowP ecommerce] } {
    doc_body_append "<li><a href=\"customer-reviews/\">Customer Reviews</a> <font size=-1>([db_string non_approved_comments_select "select count(*) from ec_product_comments where approved_p is null"] not yet approved)</font>
    <p>
    "
}

set n_not_yet_approved [db_string non_approved_users_select "select count(*) from ec_user_class_user_map where user_class_approved_p is null or user_class_approved_p='f'"]

doc_body_append "<li><a href=\"user-classes/\">User Classes</a> 
<font size=-1>($n_not_yet_approved not yet approved user[ec_decode $n_not_yet_approved 1 "" "s"])</font>

<p>
"

set multiple_retailers_p [ad_parameter -package_id [ec_id] MultipleRetailersPerProductP ecommerce]

if { $multiple_retailers_p } {
    doc_body_append "<li><a href=\"retailers/\">Retailers</a>\n"
} else {
    doc_body_append "<li><a href=\"shipping-costs/\">Shipping Costs</a>
    <li><a href=\"sales-tax/\">Sales Tax</a>\n"
}

doc_body_append "<li><a href=\"templates/\">Product Templates</a>
"

doc_body_append "<li><a href=\"mailing-lists/\">Mailing Lists</a>
<li><a href=\"email-templates/\">Email Templates</a>\n

<p>

<li><a href=\"audit-tables\">Audit [ec_system_name]</a>
</ul>

[ad_admin_footer]
"
