# issue.tcl

ad_page_contract {
    @param issue_id

    @author
    @creation-date
    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    issue_id
}

ad_require_permission [ad_conn package_id] admin

set return_url "[ad_conn url]?[export_entire_form_as_url_vars]"

set customer_service_rep [ad_get_user_id]

if {$customer_service_rep == 0} {
    ad_returnredirect "/register.tcl?[export_url_vars return_url]"
    ad_script_abort
}



set page_title "Issue #$issue_id"
append doc_body "[ad_admin_header $page_title]
<h2>$page_title</h2>

[ad_context_bar [list "../index.tcl" "Ecommerce([ec_system_name])"] [list "index.tcl" "Customer Service Administration"] $page_title]

<hr>
"



db_1row get_user_info "select i.user_identification_id, i.order_id, i.closed_by, i.deleted_p, i.open_date, i.close_date, to_char(i.open_date,'YYYY-MM-DD HH24:MI:SS') as full_open_date, to_char(i.close_date,'YYYY-MM-DD HH24:MI:SS') as full_close_date, u.first_names || ' ' || u.last_name as closed_rep_name
from ec_customer_service_issues i, cc_users u
where i.closed_by=u.user_id(+)
and issue_id=:issue_id"



if { [empty_string_p $close_date] } {
    set open_close_link "<a href=\"issue-open-or-close?close_p=t&[export_url_vars issue_id]\">close</a>"
} else {
    set open_close_link "<a href=\"issue-open-or-close?close_p=f&[export_url_vars issue_id]\">reopen</a>"
}

append doc_body "
\[ <a href=\"issue-edit?[export_url_vars issue_id]\">change issue type</a> | $open_close_link | <a href=\"email-send?[export_url_vars issue_id user_identification_id]\">send email</a> | <a href=\"interaction-add?[export_url_vars issue_id user_identification_id]\">record an interaction</a> \]

<p>

<blockquote>
<table>
<tr>
<td align=right><b>Customer</td>
<td>[ec_user_identification_summary $user_identification_id]</td>
</tr>
"

if { ![empty_string_p $order_id] } {
    append doc_body "<tr>
    <td align=right><b>Order #</td>
    <td><a href=\"../orders/one?order_id=$order_id\">$order_id</a></td>
    </tr>
    "
}

set issue_type_list [db_list get_issue_type_list "select issue_type from ec_cs_issue_type_map where issue_id=:issue_id"]
set issue_type [join $issue_type_list ", "]

if { ![empty_string_p $issue_type] } {
    append doc_body "<tr>
    <td align=right><b>Issue Type</td>
    <td>$issue_type</td>
    </tr>
    "
}

append doc_body "<tr>
<td align=right><b>Open Date</td>
<td>[util_AnsiDatetoPrettyDate [lindex [split $full_open_date " "] 0]] [lindex [split $full_open_date " "] 1]</td>
</tr>
"

if { ![empty_string_p $close_date] } {
    append doc_body "<tr>
    <td align=right><b>Close Date</td>
    <td>[util_AnsiDatetoPrettyDate [lindex [split $full_close_date " "] 0]] [lindex [split $full_close_date " "] 1]</td>
    </tr>
    <tr>
    <td align=right><b>Closed By</td>
    <td><a href=\"[ec_acs_admin_url]users/one?user_id=$closed_by\">$closed_rep_name</a></td>
    </tr>
    "
}

append doc_body "
</table>
</blockquote>

<p>

<h3>All actions associated with this issue</h3>
<center>
"

set sql "select a.action_id, a.interaction_id, a.action_details, a.follow_up_required, i.customer_service_rep, i.interaction_date, to_char(i.interaction_date,'YYYY-MM-DD HH24:MI:SS') as full_interaction_date, i.interaction_originator, i.interaction_type, m.info_used
from ec_customer_service_actions a, ec_customer_serv_interactions i, ec_cs_action_info_used_map m
where a.interaction_id=i.interaction_id
and a.action_id=m.action_id(+)
and a.issue_id=:issue_id
order by a.action_id desc"

set old_action_id ""
set info_used_list [list]
set action_counter 0
db_foreach get_actions_assoc_w_user $sql {
    incr action_counter
    
    if { [string compare $action_id $old_action_id] != 0 } {
	if { [llength $info_used_list] > 0 } {
	    append doc_body "<td>[join $info_used_list "<br>"]</td>"
	    set info_used_list [list]
	} else {
	    append doc_body "<td>&nbsp;</td>"
	}

	if { ![empty_string_p $old_action_id] } {
	    append doc_body "<td><a href=\"interaction?interaction_id=$old_interaction_id\">$old_interaction_id</a></tr>
	    <tr><td colspan=6><b>Details:</b><br><blockquote>[ec_display_as_html $old_action_details]</blockquote></td></tr>
	    "
	    if { ![empty_string_p $old_follow_up_required] } {
		append doc_body "<tr><td colspan=6><b>Follow-up Required:</b><br><blockquote>[ec_display_as_html $old_follow_up_required]</blockquote></td></tr>"
	    }
	    append doc_body "</table>
	    <p>
	    "
	}
	append doc_body "<table width=90%>
	<tr bgcolor=\"ececec\"><th>Date</th><th>Rep</th><th>Originator</th><th>Inquired Via</th><th>Info Used</th><th>Interaction</th></tr>
	<tr bgcolor=\"ececec\"><td>[util_AnsiDatetoPrettyDate [lindex [split $full_interaction_date " "] 0]] [lindex [split $full_interaction_date " "] 1]</td><td>[ec_decode $customer_service_rep "" "&nbsp;" "<a href=\"[ec_acs_admin_url]users/one?user_id=$customer_service_rep\">$customer_service_rep</a>"]</td><td>$interaction_originator</td><td>$interaction_type</td>
	"
    }

    if { ![empty_string_p $info_used] } {
	lappend info_used_list $info_used
    }
    set old_action_id $action_id
    set old_interaction_id $interaction_id
    set old_action_details $action_details
    set old_follow_up_required $follow_up_required
}

if { [llength $info_used_list] > 0 } {
    append doc_body "<td>[join $info_used_list "<br>"]</td>"
    set info_used_list [list]
} else {
    append doc_body "<td>&nbsp;</td>"
}
if { ![empty_string_p $old_action_id] } {
    append doc_body "<td><a href=\"interaction?interaction_id=$interaction_id\">$interaction_id</a></tr>
    <tr><td colspan=6><b>Details:</b><br><blockquote>[ec_display_as_html $action_details]</blockquote></td></tr>
    "
    if { ![empty_string_p $follow_up_required] } {
	append doc_body "<tr><td colspan=6><b>Follow-up Required:</b><br><blockquote>[ec_display_as_html $follow_up_required]</blockquote></td></tr>
	"
    }
    append doc_body "</table>
	    "
}

append doc_body "</center>
[ad_admin_footer]
"



doc_return  200 text/html $doc_body
