# /www/[ec_url_concat [ec_url] /admin]/orders/search.tcl
ad_page_contract {
  Order search page.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id search.tcl,v 3.2.2.3 2000/08/17 15:19:15 seb Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  order_id_query_string:integer,optional
  product_sku_query_string:optional
  product_name_query_string:optional
  customer_last_name_query_string:optional
}

ad_require_permission [ad_conn package_id] admin

doc_body_append "[ad_admin_header "Search Results"]

<h2>Search Results</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index" "Orders"] "Search Results"]

<hr>
<blockquote>
"


if { [info exists order_id_query_string] } {
    set product_header ""
    set product_name ""
    # append order_id_query_string "%"
    set order_id_query_string "%$order_id_query_string%"
    set query [db_map order_id_query_string_sql]
#    select o.order_id, o.confirmed_date, o.order_state,
#           ec_total_price(o.order_id) as price_to_display,
#           o.user_id,
#           u.first_names, u.last_name,
#           count(*) as n_items
#      from ec_orders o, cc_users u, ec_items i
#     where o.order_id like :order_id_query_string
#       and o.user_id=u.user_id(+)
#       and o.order_id=i.order_id
#  group by o.order_id, o.confirmed_date, o.order_state,
#           ec_total_price(o.order_id), o.user_id,
#           u.first_names, u.last_name
#  order by order_id
} elseif { [info exists product_sku_query_string] } {
    set product_header "<td><b>Product</b></td>"
    set product_sku_query_string "%$product_sku_query_string%"
    set query [db_map product_sku_query_string_sql]
} elseif { [info exists product_name_query_string] } {
    set product_header "<td><b>Product</b></td>"
    # append product_name_query_string "%"
    set product_name_query_string "%$product_name_query_string%"
    set query [db_map product_name_query_string_sql]
#    select o.order_id, o.confirmed_date, o.order_state,
#           ec_total_price(o.order_id) as price_to_display,
#           o.user_id,
#           u.first_names, u.last_name,
#           p.product_name,
#           count(*) as n_items
#      from ec_orders o, cc_users u, ec_items i, ec_products p
#     where upper(p.product_name) like upper(:product_name_query_string)
#       and i.product_id=p.product_id
#       and o.user_id=u.user_id(+)
#       and o.order_id=i.order_id
#  group by o.order_id, o.confirmed_date, o.order_state,
#           ec_total_price(o.order_id),
#           o.user_id,
#           u.first_names, u.last_name, p.product_name
#  order by order_id
} elseif { [info exists customer_last_name_query_string] } {
    set product_header ""
    set product_name ""
    # append customer_last_name_query_string "%"
    set customer_last_name_query_string "%$customer_last_name_query_string%"
    # This is because customer_last_name_query_string is too long to
    # be a bind variable
    set cust_last_name_query_string $customer_last_name_query_string
    set query [db_map default_sql]
#    select o.order_id, o.confirmed_date, o.order_state,
#           ec_total_price(o.order_id) as price_to_display,
#           o.user_id,
#           u.first_names, u.last_name,
#           count(*) as n_items
#      from ec_orders o, cc_users u, ec_items i
#     where upper(u.last_name) like upper(:cust_last_name_query_string)
#       and o.user_id=u.user_id(+)
#       and o.order_id=i.order_id
#  group by o.order_id, o.confirmed_date, o.order_state,
#           ec_total_price(o.order_id),
#           o.user_id,
#           u.first_names, u.last_name
#  order by order_id

}

set link_beginning "by-order-state-and-time?[export_url_vars view_order_state view_confirmed]"

set table_header "<table>
<tr>
<td><b>Order ID</b></td>
<td><b>Date Confirmed</b></td>
<td><b>Order State</b></td>
<td><b>Customer</b></td>
<td><b>Amount</b></td>
<td><b># of Items</b></td>
$product_header
</tr>"

set row_counter 0
db_foreach order_search_query $query {
    if { $row_counter == 0 } {
        doc_body_append $table_header
    }
    # even rows are white, odd are grey
    if { [expr floor($row_counter/2.)] == [expr $row_counter/2.] } {
        set bgcolor "white"
    } else {
        set bgcolor "ececec"
    }

    if {![string equal "" $product_name]} {
        set product_column "<td>$product_name</td>"
    } else {
	set product_column ""
    }

    doc_body_append "<tr bgcolor=$bgcolor>
<td><a href=\"one?[export_url_vars order_id]\">$order_id</a></td>
<td>[ec_nbsp_if_null [util_AnsiDatetoPrettyDate $confirmed_date]]</td>
<td>$order_state</td>
<td>[ec_decode $last_name "" "&nbsp;" "<a href=\"[ec_acs_admin_url]users/one?[export_url_vars user_id]\">$last_name, $first_names</a>"]</td>
<td>[ec_nbsp_if_null [ec_pretty_price $price_to_display]]</td>
<td>$n_items</td>
$product_column
</tr>
    "
    incr row_counter
}

if { $row_counter != 0 } {
    doc_body_append "</table>"
} else {
    doc_body_append "<center>None Found</center>"
}

doc_body_append "</blockquote>

[ad_admin_footer]
"
