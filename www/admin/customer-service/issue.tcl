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

set title "Issue ${issue_id}"
set context [list [list index "Customer Service"] $title]

db_1row get_user_info "select i.user_identification_id, i.order_id, i.closed_by, i.deleted_p, i.open_date, i.close_date, to_char(i.open_date,'YYYY-MM-DD HH24:MI:SS') as full_open_date, to_char(i.close_date,'YYYY-MM-DD HH24:MI:SS') as full_close_date, u.first_names || ' ' || u.last_name as closed_rep_name
from ec_customer_service_issues i, cc_users u
where i.closed_by=u.user_id(+)
and issue_id=:issue_id"

set user_id_summary_html "[ec_user_identification_summary $user_identification_id]"

if { [empty_string_p $close_date] } {
    set open_close_link "<a href=\"issue-open-or-close?close_p=t&[export_url_vars issue_id]\">close</a>"
} else {
    set open_close_link "<a href=\"issue-open-or-close?close_p=f&[export_url_vars issue_id]\">reopen</a>"
}
set choices_html "\[ <a href=\"issue-edit?[export_url_vars issue_id]\">change issue type</a> | $open_close_link | <a href=\"email-send?[export_url_vars issue_id user_identification_id]\">send email</a> | <a href=\"interaction-add?[export_url_vars issue_id user_identification_id]\">record an interaction</a> \]"

set issue_type_list [db_list get_issue_type_list "select issue_type from ec_cs_issue_type_map where issue_id=:issue_id"]
set issue_type [join $issue_type_list ", "]

set open_full_date_html [util_AnsiDatetoPrettyDate [lindex [split $full_open_date " "] 0]] [lindex [split $full_open_date " "] 1]

set close_date_html [util_AnsiDatetoPrettyDate [lindex [split $full_close_date " "] 0]] [lindex [split $full_close_date " "] 1]

set closed_by_user_id_url "[ec_acs_admin_url]users/one?user_id=$closed_by"

set sql "select a.action_id, a.interaction_id, a.action_details, a.follow_up_required, i.customer_service_rep, i.interaction_date, to_char(i.interaction_date,'YYYY-MM-DD HH24:MI:SS') as full_interaction_date, i.interaction_originator, i.interaction_type, m.info_used
from ec_customer_service_actions a, ec_customer_serv_interactions i, ec_cs_action_info_used_map m
where a.interaction_id=i.interaction_id
and a.action_id=m.action_id(+)
and a.issue_id=:issue_id
order by a.action_id desc"

set old_action_id ""
set info_used_list [list]
set action_counter 0
set actions_assoc_w_user_html ""
db_foreach get_actions_assoc_w_user $sql {
    incr action_counter
    if { [string compare $action_id $old_action_id] != 0 } {
        if { [llength $info_used_list] > 0 } {
            append actions_assoc_w_user_html "<td>[join $info_used_list "<br>"]</td>"
            set info_used_list [list]
        } else {
            append actions_assoc_w_user_html "<td>&nbsp;</td>"
        }
        if { ![empty_string_p $old_action_id] } {
            append actions_assoc_w_user_html "<td><a href=\"interaction?interaction_id=$old_interaction_id\">$old_interaction_id</a></tr>
	    <tr><td colspan=6><b>Details:</b><br><blockquote>[ec_display_as_html $old_action_details]</blockquote></td></tr>\n"
            if { ![empty_string_p $old_follow_up_required] } {
                append actions_assoc_w_user_html "<tr><td colspan=6><b>Follow-up Required:</b><br><blockquote>[ec_display_as_html $old_follow_up_required]</blockquote></td></tr>"
            }
            append actions_assoc_w_user_html "</table><br>"
        }
        append actions_assoc_w_user_html "<table width=90%>
	<tr bgcolor=\"ececec\"><th>Date</th><th>Rep</th><th>Originator</th><th>Inquired Via</th><th>Info Used</th><th>Interaction</th></tr>
	<tr bgcolor=\"ececec\"><td>[util_AnsiDatetoPrettyDate [lindex [split $full_interaction_date " "] 0]] [lindex [split $full_interaction_date " "] 1]</td><td>[ec_decode $customer_service_rep "" "&nbsp;" "<a href=\"[ec_acs_admin_url]users/one?user_id=$customer_service_rep\">$customer_service_rep</a>"]</td><td>$interaction_originator</td><td>$interaction_type</td>"
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
    append actions_assoc_w_user_html "<td>[join $info_used_list "<br>"]</td>"
    set info_used_list [list]
} else {
    append actions_assoc_w_user_html "<td>&nbsp;</td>"
}
if { ![empty_string_p $old_action_id] } {
    append actions_assoc_w_user_html "<td><a href=\"interaction?interaction_id=$interaction_id\">$interaction_id</a></tr>
    <tr><td colspan=6><b>Details:</b><br><blockquote>[ec_display_as_html $action_details]</blockquote></td></tr>\n"
    if { ![empty_string_p $follow_up_required] } {
        append actions_assoc_w_user_html "<tr><td colspan=6><b>Follow-up Required:</b><br><blockquote>[ec_display_as_html $follow_up_required]</blockquote></td></tr>\n"
    }
    append actions_assoc_w_user_html "</table>\n"
}
