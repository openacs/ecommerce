#  www/[ec_url_concat [ec_url] /admin]/products/list.tcl
ad_page_contract {
  Lists a class of products, ordered to the user's taste.

  @author Philip Greenspun (philg@mit.edu)
  @creation-date July 18, 1999
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  category_id:integer,notnull,optional
  order_by:optional
}

ad_require_permission [ad_conn package_id] admin

if { ![info exists category_id] || [empty_string_p $category_id] } {
    # we're going to give the user all products
    set title "All Products"
    set menubar_stub "list.tcl?"
    set category_exclusion_clause ""
} else {
    set category_name [db_string category_name_select "select category_name from ec_categories where category_id = :category_id"]
    set title "$category_name Products"
    set menubar_stub "list.tcl?category_id=$category_id&"
    set category_exclusion_clause "having ep.product_id in (select product_id from ec_category_product_map map where map.category_id = :category_id)"
}

if { ![info exists order_by] || [empty_string_p $order_by] || $order_by == "name"} {
    set order_by_clause "order by upper(product_name)"
    set ordering_options "<a href=\"${menubar_stub}order_by=sales\">sales</a> | name | <a href=\"${menubar_stub}order_by=age\">age</a> | <a href=\"${menubar_stub}order_by=comments\">comments</a>"
} elseif { $order_by == "sales" } {
    set order_by_clause "order by n_items_ordered desc"
    set ordering_options "sales | <a href=\"${menubar_stub}order_by=name\">name</a> | <a href=\"${menubar_stub}order_by=age\">age</a> | <a href=\"${menubar_stub}order_by=comments\">comments</a>"
} elseif { $order_by == "comments" } {
    set order_by_clause "order by n_comments desc"
    set ordering_options "<a href=\"${menubar_stub}order_by=sales\">sales</a> | <a href=\"${menubar_stub}order_by=name\">name</a> | <a href=\"${menubar_stub}order_by=age\">age</a> | comments"
} else {
    # must be age
    set order_by_clause "order by available_date desc"
    set ordering_options "<a href=\"${menubar_stub}order_by=sales\">sales</a> | <a href=\"${menubar_stub}order_by=name\">name</a> | age | <a href=\"${menubar_stub}order_by=comments\">comments</a>"
}

doc_body_append "[ad_admin_header $title]

<h2>$title</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index.tcl" "Products"] $title]

<hr>

order by $ordering_options

<ul>
"

set list_items ""

db_foreach product_select "SELECT ep.product_id, ep.product_name, ep.available_date, count(distinct eir.item_id) as n_items_ordered, count(distinct epc.comment_id) as n_comments FROM ec_products ep, ec_items_reportable eir, ec_product_comments epc WHERE ep.product_id = eir.product_id(+) AND ep.product_id = epc.product_id(+) GROUP BY ep.product_id, ep.product_name, ep.available_date $category_exclusion_clause $order_by_clause" {
    append list_items "<li><a href=\"one?[export_url_vars product_id]\">$product_name</a>
<font size=-1>(available since [util_AnsiDatetoPrettyDate $available_date]; $n_items_ordered sold"
    if { $n_comments > 0 } {
	append list_items "; <a href=\"../customer-reviews/index-2?[export_url_vars product_id]\">$n_comments customer reviews</a>"
    }
    append list_items ")</font>\n"

}

if { [empty_string_p $list_items] } {
    doc_body_append "No products found.\n"
} else {
    doc_body_append $list_items
}

doc_body_append "</ul>

[ad_admin_footer]
"
