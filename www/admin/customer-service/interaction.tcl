# interaction.tcl

ad_page_contract {
    @param interaction_id
    @author
    @creation-date
    @cvs-id interaction.tcl,v 3.2.2.4 2000/09/22 01:34:53 kevin Exp
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    interaction_id
}

ad_require_permission [ad_conn package_id] admin

set page_title "Interaction #$interaction_id"
append doc_body "[ad_admin_header $page_title]
<h2>$page_title</h2>

[ad_admin_context_bar [list "../index.tcl" "Ecommerce([ec_system_name])"] [list "index.tcl" "Customer Service Administration"] $page_title]

<hr>

<table>
<tr>
<td align=right><b>Customer</td>
"


db_1row get_one_interaction_info "select user_identification_id, customer_service_rep, to_char(interaction_date,'YYYY-MM-DD HH24:MI:SS') as full_interaction_date, interaction_originator, interaction_type, interaction_headers from ec_customer_serv_interactions where interaction_id=:interaction_id"


append doc_body "<td>[ec_user_identification_summary $user_identification_id]</td>
</tr>
"

append doc_body "<tr>
<td align=right><b>Interaction Date</td>
<td>[util_AnsiDatetoPrettyDate [lindex [split $full_interaction_date " "] 0]] [lindex [split $full_interaction_date " "] 1]</td>
</tr>
<tr>
<td align=right><b>Rep</td>
<td><a href=\"[ec_acs_admin_url]users/one?user_id=$customer_service_rep\">$customer_service_rep</a></td>
</tr>
<tr>
<td align=right><b>Originator</td>
<td>$interaction_originator</td>
</tr>
<tr>
<td align=right><b>Inquired Via</td>
<td>$interaction_type</td>
</tr>
"

if { ![empty_string_p $interaction_headers] } {
    append doc_body "<tr>
    <td align=right><b>Interaction Heade
    <tr>
    <td align=right><b>
    "
}

append doc_body "
</table>
<p>
<h3>All actions associated with this interaction</h3>
<center>
"

set sql "select a.action_details, a.follow_up_required, a.issue_id
from ec_customer_service_actions a
where a.interaction_id=:interaction_id
order by a.action_id desc"

db_foreach get_interaction_actions $sql {
    
    append doc_body "<table width=90%>
<tr bgcolor=\"ececec\"><td><b>Issue:</b> <a href=\"issue?issue_id=$issue_id\">$issue_id</a></td></tr>
<tr><td><b>Details:</b><br><blockquote>[ec_display_as_html $action_details]</blockquote></td></tr>
"
if { ![empty_string_p $follow_up_required] } {
    append doc_body "<tr><td colspan=6><b>Follow-up Required:</b><br><blockquote>[ec_display_as_html $follow_up_required]</blockquote></td></tr>
    "
}
append doc_body "</table>
<p>
"

}

append doc_body "</center>
[ad_admin_footer]
"


doc_return  200 text/html $doc_body
