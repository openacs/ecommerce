# /www/[ec_url_concat [ec_url] /admin]/orders/gift-certificates.tcl
ad_page_contract {

  View gift certificates.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id gift-certificates.tcl,v 3.2.2.3 2000/08/16 21:07:10 seb Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  {view_gift_certificate_state "reportable"}
  {view_issue_date "all"}
  {order_by "gift_certificate_id"}
}

ad_require_permission [ad_conn package_id] admin

doc_body_append "[ad_admin_header "Gift Certificate Purchase History"]

<h2>Gift Certificate Purchase History</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index" "Orders"] "Gift Certificate Purchase History"]

<hr>

<form method=post action=gift-certificates>
[export_form_vars view_issue_date order_by]

<table border=0 cellspacing=0 cellpadding=0 width=100%>
<tr bgcolor=ececec>
<td align=center><b>Gift Certificate State</b></td>
<td align=center><b>Issue Date</b></td>
</tr>
<tr>
<td align=center><select name=view_gift_certificate_state>
"

set gift_certificate_state_list [list [list reportable "reportable (authorized plus/minus avs)"] [list confirmed confirmed] [list authorized_plus_avs authorized_plus_avs] [list authorized_minus_avs authorized_minus_avs] [list failed_authorization failed_authorization]]

foreach gift_certificate_state $gift_certificate_state_list {
    if {[lindex $gift_certificate_state 0] == $view_gift_certificate_state} {
	doc_body_append "<option value=\"[lindex $gift_certificate_state 0]\" selected>[lindex $gift_certificate_state 1]"
    } else {
	doc_body_append "<option value=\"[lindex $gift_certificate_state 0]\">[lindex $gift_certificate_state 1]"
    }
}

doc_body_append "</select>
<input type=submit value=\"Change\">
</td>
<td align=center>
"

set issue_date_list [list [list last_24 "last 24 hrs"] [list last_week "last week"] [list last_month "last month"] [list all all]]

set linked_issue_date_list [list]

foreach issue_date $issue_date_list {
    if {$view_issue_date == [lindex $issue_date 0]} {
	lappend linked_issue_date_list "<b>[lindex $issue_date 1]</b>"
    } else {
	lappend linked_issue_date_list "<a href=\"gift-certificates?[export_url_vars view_gift_certificate_state order_by]&view_issue_date=[lindex $issue_date 0]\">[lindex $issue_date 1]</a>"
    }
}

doc_body_append "\[ [join $linked_issue_date_list " | "] \]

</td></tr></table>

</form>
<blockquote>
"

if { $view_gift_certificate_state == "reportable" } {
    set gift_certificate_state_query_bit "and g.gift_certificate_state in ('authorized_plus_avs','authorized_minus_avs')"
} else {
    set gift_certificate_state_query_bit "and g.gift_certificate_state=:view_gift_certificate_state"
}

if { $view_issue_date == "last_24" } {
    set issue_date_query_bit "and sysdate-g.issue_date <= 1"
} elseif { $view_issue_date == "last_week" } {
    set issue_date_query_bit "and sysdate-g.issue_date <= 7"
} elseif { $view_issue_date == "last_month" } {
    set issue_date_query_bit "and months_between(sysdate,g.issue_date) <= 1"
} else {
    set issue_date_query_bit ""
}

set link_beginning "gift-certificates?[export_url_vars view_gift_certificate_state view_issue_date]"

set order_by_clause [util_decode $order_by \
    "gift_certificate_id" "g.gift_certificate_id" \
    "issue_date" "g.issue_date" \
    "gift_certificate_state" "g.gift_certificate_state" \
    "name" "u.last_name, u.first_names" \
    "recipient_email" "g.recipient_email" \
    "amount" "g.amount"]

set table_header "<table>
<tr>
<td><b><a href=\"$link_beginning&order_by=[ns_urlencode "gift_certificate_id"]\">ID</a></b></td>
<td><b><a href=\"$link_beginning&order_by=[ns_urlencode "issue_date"]\">Date Issued</a></b></td>
<td><b><a href=\"$link_beginning&order_by=[ns_urlencode "gift_certificate_state"]\">Gift Certificate State</a></b></td>
<td><b><a href=\"$link_beginning&order_by=[ns_urlencode "name"]\">Purchased By</a></b></td>
<td><b><a href=\"$link_beginning&order_by=[ns_urlencode "recipient_email"]\">Recipient</a></b></td>
<td><b><a href=\"$link_beginning&order_by=[ns_urlencode "amount"]\">Amount</a></b></td>
</tr>"



set row_counter 0
db_foreach gift_certificates_select "select g.gift_certificate_id, g.issue_date, g.gift_certificate_state, g.recipient_email, g.purchased_by, g.amount, u.first_names, u.last_name
from ec_gift_certificates g, cc_users u
where g.purchased_by=u.user_id
$issue_date_query_bit $gift_certificate_state_query_bit
order by $order_by_clause
" {
    if { $row_counter == 0 } {
      doc_body_append $table_header
    }
    # even rows are white, odd are grey
    if { [expr floor($row_counter/2.)] == [expr $row_counter/2.] } {
	set bgcolor "white"
    } else {
	set bgcolor "ececec"
    }
    doc_body_append "<tr bgcolor=$bgcolor>
<td><a href=\"gift-certificate?[export_url_vars gift_certificate_id]\">$gift_certificate_id</a></td>
<td>[ec_nbsp_if_null [util_AnsiDatetoPrettyDate $issue_date]]</td>
<td>$gift_certificate_state</td>
<td>[ec_decode $last_name "" "&nbsp;" "<a href=\"[ec_acs_admin_url]users/one?user_id=$purchased_by\">$last_name, $first_names</a>"]</td>
<td>$recipient_email</td>
<td>[ec_pretty_price $amount]</td>
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
