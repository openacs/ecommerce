ad_page_contract {

    View gift certificates issued.

    @author Eve Andersson (eveander@arsdigita.com)
    @creation-date Summer 1999
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @revision-date April 2002

} {
    {view_rep "all"}
    {view_issue_date "last_24"}
    {order_by "gift_certificate_id"}
}

ad_require_permission [ad_conn package_id] admin

set title "Gift Certificate Issue History"
set context [list [list index "Orders / Shipments / Refunds"] $title]

set export_form_vars_html [export_form_vars view_issue_date order_by]

set customer_service_reps_select_html ""
db_foreach ec_customer_service_reps_select "select user_id as rep, first_names as rep_first_names, last_name as rep_last_name
    from ec_customer_service_reps
    order by last_name, first_names" {

    if { $view_rep == $rep } {
        append customer_service_reps_select_html "<option value=$rep selected>$rep_last_name, $rep_first_names</option>\n"
    } else {
        append customer_service_reps_select_html "<option value=$rep>$rep_last_name, $rep_first_names</option>\n"
    }
}

set issue_date_list [list [list last_24 "last 24 hrs"] [list last_week "last week"] [list last_month "last month"] [list all all]]

set linked_issue_date_list [list]
foreach issue_date $issue_date_list {
    if {$view_issue_date == [lindex $issue_date 0]} {
        lappend linked_issue_date_list "<b>[lindex $issue_date 1]</b>"
    } else {
        lappend linked_issue_date_list "<a href=\"gift-certificates-issued?[export_url_vars view_rep order_by]&view_issue_date=[lindex $issue_date 0]\">[lindex $issue_date 1]</a>"
    }
}

set linked_issue_date_list_html "\[ [join $linked_issue_date_list " | "] \]"

if { $view_issue_date == "last_24" } {
    set issue_date_query_bit [db_map last_24]
} elseif { $view_issue_date == "last_week" } {
    set issue_date_query_bit [db_map last_week]
} elseif { $view_issue_date == "last_month" } {
    set issue_date_query_bit [db_map last_month]
} else {
    set issue_date_query_bit ""
}

if [regexp {^[0-9]+$} $view_rep] {
    set rep_query_bit "and g.issued_by = :view_rep"
} else {
    set rep_query_bit ""
}

set link_beginning "gift-certificates-issued?[export_url_vars view_rep view_issue_date]"

set order_by_clause [ec_decode $order_by \
			 "gift_certificate_id" "g.gift_certificate_id" \
			 "issue_date" "g.issue_date" \
			 "issued_by" "u.last_name, u.first_names" \
			 "recipient" "r.last_name, r.first_names" \
			 "amount" "g.amount"]

set table_header "<td><b><a href=\"$link_beginning&order_by=[ns_urlencode "gift_certificate_id"]\">ID</a></b></td>
        <td><b><a href=\"$link_beginning&order_by=[ns_urlencode "issue_date"]\">Date Issued</a></b></td>
        <td><b><a href=\"$link_beginning&order_by=[ns_urlencode "issued_by"]\">Issued By</a></b></td>
        <td><b><a href=\"$link_beginning&order_by=[ns_urlencode "recipient"]\">Recipient</a></b></td>
        <td><b><a href=\"$link_beginning&order_by=[ns_urlencode "amount"]\">Amount</a></b></td>"

set row_counter 0
set gift_certificates_select_html ""
db_foreach gift_certificates_select "select g.gift_certificate_id, g.issue_date, g.amount,
       g.issued_by, u.first_names, u.last_name,
       g.user_id as issued_to, r.first_names as issued_to_first_names, r.last_name as issued_to_last_name
    from ec_gift_certificates_issued g, cc_users u, cc_users r
    where g.issued_by=u.user_id and g.user_id=r.user_id
    $issue_date_query_bit $rep_query_bit
    order by $order_by_clause" {

    # even rows are white, odd are grey
    if { [expr floor($row_counter/2.)] == [expr $row_counter/2.] } {
        set bgcolor "#ffffff"
    } else {
        set bgcolor "#ececec"
    }
    append gift_certificates_select_html "<tr bgcolor=$bgcolor>
 	  <td><a href=\"gift-certificate?[export_url_vars gift_certificate_id]\">$gift_certificate_id</a></td>
	  <td>[ec_nbsp_if_null [util_AnsiDatetoPrettyDate $issue_date]]</td>
	  <td>[ec_decode $last_name "" "&nbsp;" "<a href=\"[ec_acs_admin_url]users/one?user_id=$issued_by\">$last_name, $first_names</a>"]</td>
	  <td>[ec_decode $last_name "" "&nbsp;" "<a href=\"[ec_acs_admin_url]users/one?user_id=$issued_to\">$issued_to_last_name, $issued_to_first_names</a>"]</td>
	  <td>[ec_pretty_pure_price $amount]</td></tr>"
    incr row_counter
}

