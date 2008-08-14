#  www/[ec_url_concat [ec_url] /admin]/products/list.tcl
ad_page_contract {
    Lists a class of products, ordered to the user's taste.

    @param how_many How many products to display on the page
    @param start_row Where to begin from

    @author Philip Greenspun (philg@mit.edu)
    @creation-date July 18, 1999
    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    category_id:integer,notnull,optional
    order_by:optional
    {how_many:naturalnum {[ad_parameter -package_id [ec_id] ProductsToDisplayPerPage ecommerce]}}
    {start_row:naturalnum "0"}
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
    set ordering_options "<a href=\"${menubar_stub}order_by=sales\">sales</a> | name | <a href=\"${menubar_stub}order_by=age\">age</a> | <a href=\"${menubar_stub}order_by=comments\">comments</a> | <a href=\"${menubar_stub}order_by=last_edit_date\">last modified</a>"
} elseif { $order_by == "sales" } {
    set order_by_clause "order by n_items_ordered desc"
    set ordering_options "sales | <a href=\"${menubar_stub}order_by=name\">name</a> | <a href=\"${menubar_stub}order_by=age\">age</a> | <a href=\"${menubar_stub}order_by=comments\">comments</a> | <a href=\"${menubar_stub}order_by=last_edit_date\">last modified</a>"
} elseif { $order_by == "comments" } {
    set order_by_clause "order by n_comments desc"
    set ordering_options "<a href=\"${menubar_stub}order_by=sales\">sales</a> | <a href=\"${menubar_stub}order_by=name\">name</a> | <a href=\"${menubar_stub}order_by=age\">age</a> | comments | <a href=\"${menubar_stub}order_by=last_edit_date\">last modified</a>"
} elseif { $order_by == "last_edit_date" } {
    set order_by_clause "order by last_modified desc"
    set ordering_options "<a href=\"${menubar_stub}order_by=sales\">sales</a> | <a href=\"${menubar_stub}order_by=name\">name</a> | <a href=\"${menubar_stub}order_by=age\">age</a> | <a href=\"${menubar_stub}order_by=comments\">comments</a> | last modified"
} else {
    # must be age
    set order_by_clause "order by available_date desc"
    set ordering_options "<a href=\"${menubar_stub}order_by=sales\">sales</a> | <a href=\"${menubar_stub}order_by=name\">name</a> | age | <a href=\"${menubar_stub}order_by=comments\">comments</a> | <a href=\"${menubar_stub}order_by=last_edit_date\">last modified</a>"
}

set header " order by $ordering_options"
set context [list [list index Products] $title]



set list_items ""

set have_how_many_more_p f
set count $start_row

if {[info exists category_id]} { 
    db_1row product_select_count_for_category "
    select count(product_id) as product_count
    from ec_category_product_map map
    where map.category_id = :category_id
    "
} else {
    db_1row product_select_count_all "
    select count(product_id) as product_count
    from ec_products
    "
}

db_foreach product_select "SELECT ep.product_id, ep.product_name, ep.available_date, ep.last_modified, count(distinct eir.item_id) as n_items_ordered, count(distinct epc.comment_id) as n_comments FROM ec_products ep, ec_items_reportable eir, ec_product_comments epc WHERE ep.product_id = eir.product_id(+) AND ep.product_id = epc.product_id(+) GROUP BY ep.product_id, ep.product_name, ep.available_date, ep.last_modified $category_exclusion_clause $order_by_clause" {

    append list_items "<li><a href=\"one?[export_url_vars product_id]\">$product_name</a>
    <font size=-1>(available since [util_AnsiDatetoPrettyDate $available_date]; $n_items_ordered sold"
    if { $n_comments > 0 } {
        append list_items "; <a href=\"../customer-reviews/index-2?[export_url_vars product_id]\">$n_comments customer reviews</a>"
    }
    append list_items ")</font></li>"
    incr count
}
if { $product_count > [expr $start_row + (2 * $how_many)] } {
    # We know there are at least how_many more items to display
    # next time
    set have_how_many_more_p t
} else {
    set have_how_many_more_p f
}

if { [empty_string_p $list_items] } {
    set list_items "<p>No products found.</p>"
} else {
    set list_items "<ul>$list_items</ul>"
}

if { $start_row >= $how_many } {
    set prev_link "<a href=\"[ad_conn url]?[export_url_vars category_id how_many]&start_row=[expr $start_row - $how_many]\">Previous $how_many</a>"
} else {
    set prev_link ""
}

if { $have_how_many_more_p == "t" } {
    set next_link "<a href=\"[ad_conn url]?[export_url_vars category_id how_many]&start_row=[expr $start_row + $how_many]\">Next $how_many</a>"
} else {
    set number_of_remaining_products [expr $product_count - $start_row - $how_many]
    if { $number_of_remaining_products > 0 } {
        set next_link "<a href=\"[ad_conn url]?[export_url_vars category_id how_many]&start_row=[expr $start_row + $how_many]\">Next $number_of_remaining_products</a>"
    } else {
        set next_link ""
    }
}

if { [empty_string_p $next_link] || [empty_string_p $prev_link] } {
    set separator ""
} else {
    set separator "|"
}

