# /www/[ec_url_concat [ec_url] /admin]/orders/refunds.tcl
ad_page_contract {
  View refunds.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id refunds.tcl,v 3.2.2.3 2000/08/17 15:19:15 seb Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  {view_refund_date "all"}
  {order_by "refund_id"}
}

ad_require_permission [ad_conn package_id] admin

doc_body_append "[ad_admin_header "Refund History"]

<h2>Refund History</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index" "Orders"] "Refund History"]

<hr>

<table border=0 cellspacing=0 cellpadding=0 width=100%>
<tr bgcolor=\"ececec\">
<td align=center><b>Refund Date</b></td>
</tr>
<tr>
<td align=center>
"

set refund_date_list [list [list last_24 "last 24 hrs"] [list last_week "last week"] [list last_month "last month"] [list all all]]

set linked_refund_date_list [list]

foreach refund_date $refund_date_list {
    if {$view_refund_date == [lindex $refund_date 0]} {
	lappend linked_refund_date_list "<b>[lindex $refund_date 1]</b>"
    } else {
	lappend linked_refund_date_list "<a href=\"refunds?[export_url_vars order_by]&view_refund_date=[lindex $refund_date 0]\">[lindex $refund_date 1]</a>"
    }
}

doc_body_append "\[ [join $linked_refund_date_list " | "] \]

</td></tr></table>

</form>
<blockquote>
"

if { $view_refund_date == "last_24" } {
    #set refund_date_query_bit "and sysdate-r.refund_date <= 1"
    set refund_date_query_bit [db_map last_24]
} elseif { $view_refund_date == "last_week" } {
    #set refund_date_query_bit "and sysdate-r.refund_date <= 7"
    set refund_date_query_bit [db_map last_week]
} elseif { $view_refund_date == "last_month" } {
    #set refund_date_query_bit "and months_between(sysdate,r.refund_date) <= 1"
    set refund_date_query_bit [db_map last_month]
} else {
    set refund_date_query_bit ""
}

set link_beginning "refunds?[export_url_vars view_refund_date]"

set order_by_clause [util_decode $order_by \
    "refund_id" "r.refund_id" \
    "refund_date" "r.refund_date" \
    "order_id" "r.order_id" \
    "refund_amount" "r.refund_amount" \
    "n_items" "n_items" \
    "name" "u.last_name, u.first_names"]

set table_header "<table>
<tr>
<td><b><a href=\"$link_beginning&order_by=[ns_urlencode "refund_id"]\">Refund ID</a></b></td>
<td><b><a href=\"$link_beginning&order_by=[ns_urlencode "refund_date"]\">Date Refunded</a></b></td>
<td><b><a href=\"$link_beginning&order_by=[ns_urlencode "order_id"]\">Order ID</a></b></td>
<td><b><a href=\"$link_beginning&order_by=[ns_urlencode "refund_amount"]\">Amount</a></b></td>
<td><b><a href=\"$link_beginning&order_by=[ns_urlencode "n_items"]\"># of Items</a></b></td>
<td><b><a href=\"$link_beginning&order_by=[ns_urlencode "name"]\">By</a></b></td>
</tr>"


set row_counter 0
db_foreach refunds_select "select r.refund_id, r.refund_date, r.order_id, r.refund_amount, r.refunded_by, u.first_names, u.last_name, count(*) as n_items
from ec_refunds r, cc_users u, ec_items i
where r.refunded_by=u.user_id
and i.refund_id=r.refund_id
$refund_date_query_bit
group by r.refund_id, r.refund_date, r.order_id, r.refund_amount, r.refunded_by, u.first_names, u.last_name
order by $order_by_clause" {
    if { $row_counter == 0 } {
	doc_body_append $table_header
    }
    # even rows are white, odd are grey
    if { [expr floor($row_counter/2.)] == [expr $row_counter/2.] } {
	set bgcolor "white"
    } else {
	set bgcolor "ececec"
    }
    doc_body_append "<tr bgcolor=\"$bgcolor\">
<td>$refund_id</td>
<td>[util_AnsiDatetoPrettyDate $refund_date]</td>
<td><a href=\"one?[export_url_vars order_id]\">$order_id</a></td>
<td>[ec_pretty_price $refund_amount]</td>
<td>$n_items</td>
<td><a href=\"[ec_acs_admin_url]users/one?user_id=$refunded_by\">$last_name, $first_names</a></td></tr>
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
