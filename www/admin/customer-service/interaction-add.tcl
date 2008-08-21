# interaction-add.tcl
ad_page_contract { 
    @param issue_id:optional
    @param user_identification_id:optional

    @author
    @creation-date
    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    issue_id:optional
    user_identification_id:optional
}

ad_require_permission [ad_conn package_id] admin

# the customer service rep must be logged on
set return_url "[ad_conn url]"

set customer_service_rep [ad_get_user_id]

if {$customer_service_rep == 0} {
    ad_returnredirect "/register?[export_url_vars return_url]"
    ad_script_abort
}

if { [info exists issue_id] } {
    set return_to_issue $issue_id
}
if { [info exists user_identification_id] } {
    set c_user_identification_id $user_identification_id
}

set insert_id 0

set title "New Interaction"
set context [list [list index "Customer Service"] $title]

set export_form_vars_html [export_form_vars issue_id return_to_issue c_user_identification_id insert_id]
set table_rows_html ""

if { [info exists user_identification_id] } {
    append table_rows_html "<tr><td>Customer:</td><td>[ec_user_identification_summary $user_identification_id]</td></tr>\n"
}

append early_message "Customer Service Rep: [db_string get_full_name "select first_names || ' ' || last_name from cc_users where user_id=:customer_service_rep"] (if this is wrong, please <a href=\"/register?[export_url_vars return_url]\">log in</a>)"

set date_time_widget_html "[ad_dateentrywidget open_date] [ec_timeentrywidget open_date "[ns_localsqltimestamp]"]"

set interaction_widget_html [ec_interaction_type_widget]
