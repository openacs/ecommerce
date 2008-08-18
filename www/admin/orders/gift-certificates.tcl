ad_page_contract {

    View gift certificates.

    @author Eve Andersson (eveander@arsdigita.com)
    @creation-date Summer 1999
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @revision-date March 2002

} {
    {view_gift_certificate_state "reportable"}
    {view_issue_date "last_24"}
    {order_by "gift_certificate_id"}
}

ad_require_permission [ad_conn package_id] admin

set title "Gift Certificate Purchase History"
set context [list [list index "Orders / Shipments / Refunds"] $title]

set export_form_vars_html [export_form_vars view_issue_date order_by]

set gift_certificate_state_list [list \
				     [list confirmed confirmed] \
				     [list authorized authorized] \
				     [list failed_authorization failed_authorization]]

set gift_certificate_state_list_html ""
foreach gift_certificate_state $gift_certificate_state_list {
    if {[lindex $gift_certificate_state 0] == $view_gift_certificate_state} {
        append gift_certificate_state_list_html "<option value=\"[lindex $gift_certificate_state 0]\" selected>[lindex $gift_certificate_state 1]</option>"
    } else {
        append gift_certificate_state_list_html "<option value=\"[lindex $gift_certificate_state 0]\">[lindex $gift_certificate_state 1]</option>"
    }
}

set issue_date_list [list [list last_24 "last 24 hrs"] [list last_week "last week"] [list last_month "last month"] [list all all]]

set linked_issue_date_list [list]
foreach issue_date $issue_date_list {
    if {$view_issue_date == [lindex $issue_date 0]} {
        lappend linked_issue_date_list "<b>[lindex $issue_date 1]</b>"
    } else {
        lappend linked_issue_date_list "<a href=\"gift-certificates?[export_url_vars view_gift_certificate_state order_by]&view_issue_date=[lindex $issue_date 0]\">[lindex $issue_date 1]</a>"
    }
}

set linked_issue_date_list_html "\[ [join $linked_issue_date_list " | "] \]"

set gift_certificate_state_query_bit "and g.gift_certificate_state=:view_gift_certificate_state"

if { $view_issue_date == "last_24" } {
    set issue_date_query_bit [db_map last_24]
} elseif { $view_issue_date == "last_week" } {
    set issue_date_query_bit [db_map last_week]
} elseif { $view_issue_date == "last_month" } {
    set issue_date_query_bit [db_map last_month]
} else {
    set issue_date_query_bit ""
}

set link_beginning "gift-certificates?[export_url_vars view_gift_certificate_state view_issue_date]"

set order_by_clause [ec_decode $order_by \
			 "gift_certificate_id" "g.gift_certificate_id" \
			 "issue_date" "g.issue_date" \
			 "gift_certificate_state" "g.gift_certificate_state" \
			 "name" "u.last_name, u.first_names" \
			 "recipient_email" "g.recipient_email" \
			 "amount" "g.amount"]

set table_header_html "<td><b><a href=\"$link_beginning&order_by=[ns_urlencode "gift_certificate_id"]\">ID</a></b></td>
        <td><b><a href=\"$link_beginning&order_by=[ns_urlencode "issue_date"]\">Date Issued</a></b></td>
        <td><b><a href=\"$link_beginning&order_by=[ns_urlencode "gift_certificate_state"]\">Gift Certificate State</a></b></td>
        <td><b><a href=\"$link_beginning&order_by=[ns_urlencode "name"]\">Purchased By</a></b></td>
        <td><b><a href=\"$link_beginning&order_by=[ns_urlencode "recipient_email"]\">Recipient</a></b></td>
        <td><b><a href=\"$link_beginning&order_by=[ns_urlencode "amount"]\">Amount</a></b></td>"

set row_counter 0
set gift_certificates_select_html ""
db_foreach gift_certificates_select "
    select g.gift_certificate_id, g.issue_date, g.gift_certificate_state, g.recipient_email, g.purchased_by, g.amount, u.first_names, u.last_name
    from ec_gift_certificates g, cc_users u
    where g.purchased_by=u.user_id
    $issue_date_query_bit $gift_certificate_state_query_bit
    order by $order_by_clause" {

    # Even rows are white, odd are grey
    if { [expr floor($row_counter/2.)] == [expr $row_counter/2.] } {
        set bgcolor "#ffffff"
    } else {
        set bgcolor "#ececec"
    }
    append gift_certificates_select_html "<tr bgcolor=$bgcolor>
	  <td><a href=\"gift-certificate?[export_url_vars gift_certificate_id]\">$gift_certificate_id</a></td>
	  <td>[ec_nbsp_if_null [util_AnsiDatetoPrettyDate $issue_date]]</td>
	  <td>$gift_certificate_state</td>
	  <td>[ec_decode $last_name "" "&nbsp;" "<a href=\"[ec_acs_admin_url]users/one?user_id=$purchased_by\">$last_name, $first_names</a>"]</td>
	  <td>$recipient_email</td>
	  <td>[ec_pretty_pure_price $amount]</td></tr>"
    incr row_counter
}
