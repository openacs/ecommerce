ad_page_contract {
    View orders by order state and order time.

    @author Eve Anderson (eveander@arsdigita.com)
    @author Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @creation-date Summer 1999
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @revision-date April 2002

} {
    {view_order_state "reportable"}
    {view_confirmed "last_24"}
    {order_by "order_id"}
}

ad_require_permission [ad_conn package_id] admin

doc_body_append "
    [ad_admin_header "Order History"]

    <h2>Order History</h2>

    [ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index" "Orders"] "History"]
    <hr>

    <form method=post action=by-order-state-and-time>
      [export_form_vars view_confirmed order_by]
      <table border=0 cellspacing=0 cellpadding=0 width=100%>
        <tr bgcolor=ececec>
	  <td align=center><b>Order State</b></td>
          <td align=center><b>Confirmed Date</b></td>
        </tr>
        <tr>
          <td align=center><select name=view_order_state>"

set order_state_list [list \
			  [list reportable "reportable (authorized, partially fulfilled, or fulfilled)"] \
			  [list in_basket in_basket] \
			  [list expired expired] \
			  [list confirmed confirmed] \
			  [list authorized authorized] \
			  [list failed_authorization failed_authorization] \
			  [list partially_fulfilled partially_fulfilled] \
			  [list fulfilled fulfilled] \
			  [list returned returned] \
			  [list void void]]

foreach order_state $order_state_list {
    if {[lindex $order_state 0] == $view_order_state} {
	doc_body_append "<option value=\"[lindex $order_state 0]\" selected>[lindex $order_state 1]"
    } else {
	doc_body_append "<option value=\"[lindex $order_state 0]\">[lindex $order_state 1]"
    }
}

doc_body_append "
      </select>
      <input type=submit value=\"Change\">
    </td>
    <td align=center>"

set confirmed_list [list [list last_24 "last 24 hrs"] [list last_week "last week"] [list last_month "last month"] [list all all]]

set linked_confirmed_list [list]

foreach confirmed $confirmed_list {
    if {$view_confirmed == [lindex $confirmed 0]} {
	lappend linked_confirmed_list "<b>[lindex $confirmed 1]</b>"
    } else {
	lappend linked_confirmed_list "<a href=\"by-order-state-and-time?[export_url_vars view_order_state order_by]&view_confirmed=[lindex $confirmed 0]\">[lindex $confirmed 1]</a>"
    }
}

doc_body_append "
          \[ [join $linked_confirmed_list " | "] \]
        </td>
      </tr>
    </table>
   </form>
   <blockquote>"

if { $view_order_state == "reportable" } {
    set order_state_query_bit "and o.order_state in ('authorized', 'partially_fulfilled', 'fulfilled')"
} else {
    set order_state_query_bit "and o.order_state=:view_order_state"
}

if { $view_confirmed == "last_24" } {
    set confirmed_query_bit [db_map last_24]
} elseif { $view_confirmed == "last_week" } {
    set confirmed_query_bit [db_map last_week]
} elseif { $view_confirmed == "last_month" } {
    set confirmed_query_bit [db_map last_month]
} else {
    set confirmed_query_bit [db_map all]
}

set link_beginning "by-order-state-and-time?[export_url_vars view_order_state view_confirmed]"

set order_by_clause [ec_decode $order_by \
			 "order_id" "order_id" \
			 "confirmed_date" "confirmed_date" \
			 "order_state" "order_state" \
			 "name" "last_name, first_names" \
			 "price" "ec_total_price(o.order_id)" \
			 "n_items" "n_items"]

set table_header "
    <table>
      <tr>
        <td><b><a href=\"$link_beginning&order_by=[ns_urlencode "order_id"]\">Order ID</a></b></td>
        <td><b><a href=\"$link_beginning&order_by=[ns_urlencode "confirmed_date"]\">Date Confirmed</a></b></td>
        <td><b><a href=\"$link_beginning&order_by=[ns_urlencode "order_state"]\">Order State</a></b></td>
        <td><b><a href=\"$link_beginning&order_by=[ns_urlencode "name"]\">Customer</a></b></td>
        <td><b><a href=\"$link_beginning&order_by=[ns_urlencode "price"]\">Amount</a></b></td>
        <td><b><a href=\"$link_beginning&order_by=[ns_urlencode "n_items"]\"># of Items</a></b></td>
      </tr>"

set row_counter 0
db_foreach orders_select "
    select o.order_id, o.confirmed_date, o.order_state, ec_total_price(o.order_id) as price_to_display, o.user_id, u.first_names, u.last_name, count(*) as n_items
    from ec_orders o, cc_users u, ec_items i
    where o.user_id=u.user_id(+)
    and o.order_id=i.order_id
    $confirmed_query_bit $order_state_query_bit
    group by o.order_id, o.confirmed_date, o.order_state, ec_total_price(o.order_id), o.user_id, u.first_names, u.last_name
    order by $order_by_clause" {

	if { $row_counter == 0 } {
	    doc_body_append $table_header
	} elseif { $row_counter == 20 } {
	    doc_body_append "</table>
      <p>
      $table_header
      "
	    set row_counter 1
	}

	# Even rows are white, odd are grey

	if { [expr floor($row_counter/2.)] == [expr $row_counter/2.] } {
	    set bgcolor "white"
	} else {
	    set bgcolor "ececec"
	}
	
	doc_body_append "
	    <tr bgcolor=\"$bgcolor\">
	      <td><a href=\"one?[export_url_vars order_id]\">$order_id</a></td>
	      <td>[ec_nbsp_if_null [util_AnsiDatetoPrettyDate $confirmed_date]]</td>
	      <td>$order_state</td>
	      <td>[ec_decode $last_name "" "&nbsp;" "<a href=\"[ec_acs_admin_url]users/one?[export_url_vars user_id]\">$last_name, $first_names</a>"]</td>
	      <td>[ec_nbsp_if_null [ec_pretty_price $price_to_display]]</td>
	      <td>$n_items</td>
	    </tr>"
    incr row_counter
}

if { $row_counter != 0 } {
    doc_body_append "
	</table>"
} else {
    doc_body_append "
	<center>None Found</center>"
}

doc_body_append "
    </blockquote>

    [ad_admin_footer]"
