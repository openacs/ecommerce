# interaction-summary.tcl

ad_page_contract {  
    @param user_id:optional
    @param user_interaction_id:optional

    @author
    @creation-date
    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    user_id:optional
    user_interaction_id:optional
}

ad_require_permission [ad_conn package_id] admin

set title "Interaction Summary"
set context [list [list index "Customer Service"] $title]

set customer_html ""
if { [info exists user_id] } {
    append customer_html "Registered user: <a href=\"[ec_acs_admin_url]users/one?user_id=$user_id\">[db_string get_full_name "select first_names || ' ' || last_name from cc_users where user_id=:user_id"]</a>"
} else {
    append customer_html "[ec_user_identification_summary $user_identification_id]"
}

if { [info exists user_id] } {
    set sql "select a.issue_id, a.action_id, a.interaction_id, a.action_details, a.follow_up_required, i.customer_service_rep, i.interaction_date, to_char(i.interaction_date,'YYYY-MM-DD HH24:MI:SS') as full_interaction_date, i.interaction_originator, i.interaction_type, reps.first_names || ' ' || reps.last_name as rep_name
    from ec_customer_service_actions a, ec_customer_serv_interactions i, ec_user_identification id, users reps
    where a.interaction_id=i.interaction_id
    and i.user_identification_id=id.user_identification_id
    and id.user_id=:user_id
    and i.customer_service_rep = reps.user_id(+)
    order by a.action_id desc"

} else {
    set sql "select a.issue_id, a.action_id, a.interaction_id, a.action_details, a.follow_up_required, i.customer_service_rep, i.interaction_date, to_char(i.interaction_date,'YYYY-MM-DD HH24:MI:SS') as full_interaction_date, i.interaction_originator, i.interaction_type, reps.first_names || ' ' || reps.last_name as rep_name
    from ec_customer_service_actions a, ec_customer_serv_interactions i, ec_user_identification id
    where a.interaction_id=i.interaction_id
    and i.user_identification_id=:user_identification_id
    and i.customer_service_rep = reps.user_id
    order by a.action_id desc"
}

set old_interaction_id ""
set action_counter 0
set interaction_summary_html ""
db_foreach get_interaction_summary $sql {
    incr action_counter
    if { [string compare $interaction_id $old_interaction_id] != 0 } {
        append interaction_summary_html "<br><table width=90%>
    <tr><td colspan="3" bgcolor=\"ececec\"><b>[ec_formatted_full_date $full_interaction_date]</b></td></tr>
	<tr><td align=right><b>Rep</td><td><a href=\"[ec_acs_admin_url]users/one?user_id=$customer_service_rep\">$rep_name</a></td></tr>
	<tr><td align=right><b>Originator</td><td>$interaction_originator</td></tr>
	<tr><td align=right><b>Via</td><td>$interaction_type</td></tr>
   </table>"
    }
    append interaction_summary_html "<br>
    <table width=90%>
    <tr bgcolor=\"ececec\"><td>Issue ID: <a href=\"issue?issue_id=$issue_id\">$issue_id</a></td></tr>
    <tr><td><p><b>Details:</b>[ec_display_as_html $action_details]</td></tr>\n"
    if { ![empty_string_p $follow_up_required] } {
        append interaction_summary_html "<tr><td><p><b>Follow-up Required</b>: [ec_display_as_html $follow_up_required]</p></td></tr>\n"
    }
    append interaction_summary_html "</table>"
    set old_interaction_id $interaction_id
}

