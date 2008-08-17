ad_page_contract {

    View refunds.

    @author Eve Andersson (eveander@arsdigita.com)
    @creation-date Summer 1999
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @revision-date April 2002

} {
    {view_refund_date "last_24"}
    {order_by "refund_id"}
}

ad_require_permission [ad_conn package_id] admin

set title "Refund History"
set context [list [list index "Orders / Shipments / Refunds"] $title]

set refund_date_list [list [list last_24 "last 24 hrs"] [list last_week "last week"] [list last_month "last month"] [list all all]]

set linked_refund_date_list [list]
foreach refund_date $refund_date_list {
    if {$view_refund_date == [lindex $refund_date 0]} {
        lappend linked_refund_date_list "<b>[lindex $refund_date 1]</b>"
    } else {
        lappend linked_refund_date_list "<a href=\"refunds?[export_url_vars order_by]&view_refund_date=[lindex $refund_date 0]\">[lindex $refund_date 1]</a>"
    }
}

set linked_refund_date_list_html "\[ [join $linked_refund_date_list " | "] \]"

if { $view_refund_date == "last_24" } {
    set refund_date_query_bit [db_map last_24]
} elseif { $view_refund_date == "last_week" } {
    set refund_date_query_bit [db_map last_week]
} elseif { $view_refund_date == "last_month" } {
    set refund_date_query_bit [db_map last_month]
} else {
    set refund_date_query_bit ""
}

set link_beginning "refunds?[export_url_vars view_refund_date]"

set order_by_clause [ec_decode $order_by \
             "refund_id" "r.refund_id" \
             "refund_date" "r.refund_date" \
             "order_id" "r.order_id" \
             "refund_amount" "r.refund_amount" \
             "n_items" "n_items" \
             "name" "u.last_name, u.first_names"]

set table_header "
    <table>
      <tr>
        <td><b><a href=\"$link_beginning&order_by=[ns_urlencode "refund_id"]\">Refund ID</a></b></td>
        <td><b><a href=\"$link_beginning&order_by=[ns_urlencode "refund_date"]\">Date Refunded</a></b></td>
        <td><b><a href=\"$link_beginning&order_by=[ns_urlencode "order_id"]\">Order ID</a></b></td>
        <td><b><a href=\"$link_beginning&order_by=[ns_urlencode "refund_amount"]\">Amount</a></b></td>
        <td><b><a href=\"$link_beginning&order_by=[ns_urlencode "n_items"]\"># of Items</a></b></td>
        <td><b><a href=\"$link_beginning&order_by=[ns_urlencode "name"]\">By</a></b></td>
      </tr>"

set row_counter 0
set refunds_select_html ""
db_foreach refunds_select "
    select r.refund_id, r.refund_date, r.order_id, r.refund_amount, r.refunded_by, u.first_names, u.last_name, count(*) as n_items
    from ec_refunds r, cc_users u, ec_items i
    where r.refunded_by=u.user_id
    and i.refund_id=r.refund_id
    $refund_date_query_bit
    group by r.refund_id, r.refund_date, r.order_id, r.refund_amount, r.refunded_by, u.first_names, u.last_name
    order by $order_by_clause" {

    # Even rows are white, odd are grey
    if { [expr floor($row_counter/2.)] == [expr $row_counter/2.] } {
        set bgcolor "#white"
    } else {
        set bgcolor "#ececec"
    }
    append refunds_select_html "<tr bgcolor=\"$bgcolor\">
      <td>$refund_id</td>
      <td>[util_AnsiDatetoPrettyDate $refund_date]</td>
      <td><a href=\"one?[export_url_vars order_id]\">$order_id</a></td>
      <td>[ec_pretty_pure_price $refund_amount]</td>
      <td>$n_items</td>
      <td><a href=\"[ec_acs_admin_url]users/one?user_id=$refunded_by\">$last_name, $first_names</a></td></tr>"
    incr row_counter
}

