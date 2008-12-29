# interaction.tcl
ad_page_contract {
    @param interaction_id
    @author
    @creation-date
    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    interaction_id
}

ad_require_permission [ad_conn package_id] admin

set title "Interaction ${interaction_id}"
set context [list [list index "Customer Service"] $title]

db_1row get_one_interaction_info "select user_identification_id, customer_service_rep, to_char(interaction_date,'YYYY-MM-DD HH24:MI:SS') as full_interaction_date, interaction_originator, interaction_type, interaction_headers from ec_customer_serv_interactions where interaction_id=:interaction_id"

set interaction_date_html [util_AnsiDatetoPrettyDate [lindex [split $full_interaction_date " "] 0]] [lindex [split $full_interaction_date " "] 1]
set user_id_summary_html [ec_user_identification_summary $user_identification_id]
set rep_html "<a href=\"[ec_acs_admin_url]users/one?user_id=$customer_service_rep\">$customer_service_rep</a>"

set sql "select a.action_details, a.follow_up_required, a.issue_id
from ec_customer_service_actions a
where a.interaction_id=:interaction_id
order by a.action_id desc"
set interaction_actions_html ""
db_foreach get_interaction_actions $sql {
    append interaction_actions_html "<table width=\"90%\">
<tr bgcolor=\"ececec\"><td><b>Issue:</b> <a href=\"issue?issue_id=$issue_id\">$issue_id</a></td></tr>
<tr><td><b>Details:</b><br>[ec_display_as_html $action_details]</td></tr>\n"
    if { ![empty_string_p $follow_up_required] } {
        append interaction_actions_html "<tr><td><b>Follow-up Required:</b><br>[ec_display_as_html $follow_up_required]</td></tr>\n"
    }
    append interaction_actions_html "</table>\n"
}

