# index.tcl

ad_page_contract {
    @author
    @creation-date
    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
}
 
ad_require_permission [ad_conn package_id] admin

set title "Customer Service"
set context [list $title]

set num_open_issues [db_string get_open_issues "select count(*) 
from ec_customer_service_issues issues, ec_user_identification id
where issues.user_identification_id = id.user_identification_id
and close_date is NULL 
and deleted_p = 'f'
and 0 = (select count(*) from ec_cs_issue_type_map map where map.issue_id=issues.issue_id)"]

# only want to show issue types in the issue type widget, and then clump all others under "other"
set issue_type_list [db_list get_issue_type_list "select picklist_item from ec_picklist_items where picklist_name='issue_type' order by sort_key"]
set issue_type_list_len [llength $issue_type_list]

set issue_type_list_html ""
foreach issue_type $issue_type_list {
    set num_open_issues [db_string get_open_issues_of_type "select count(*) 
from ec_customer_service_issues issues, ec_user_identification id
where issues.user_identification_id = id.user_identification_id
and close_date is NULL 
and deleted_p = 'f'
and 1 <= (select count(*) from ec_cs_issue_type_map map where map.issue_id=issues.issue_id and map.issue_type=:issue_type)"]
    if {$num_open_issues > 0 } {
        append issue_type_list_html "<tr><td align=\"right\">$issue_type </td><td> 
<a href=\"issues?view_issue_type=[ns_urlencode $issue_type]\">$num_open_issues open</a> </td><td> <a href=\"issues?view_issue_type=[ns_urlencode $issue_type]&view_status=closed\">closed</a>
</td></tr>\n"
    } else {
        append issue_type_list_html "<tr><td align=\"right\">$issue_type </td><td> 
<a href=\"issues?view_issue_type=[ns_urlencode $issue_type]\">none</a></td><td> <a href=\"issues?view_issue_type=[ns_urlencode $issue_type]&view_status=closed\">closed</a>
</td></tr>\n"
    }
}

# same query for issues that aren't in issue_type_list
if { $issue_type_list_len > 0 } {
    # taking advantage of the fact that tcl lists are just strings
    set safe_issue_type_list [DoubleApos $issue_type_list]
    set last_bit_of_query "and 1 <= (select count(*) from ec_cs_issue_type_map map where map.issue_id=issues.issue_id and map.issue_type not in ('[join $safe_issue_type_list "', '"]'))"
} else {
    set last_bit_of_query "and 1 <= (select count(*) from ec_cs_issue_type_map map where map.issue_id=issues.issue_id)"
}

set num_open_issues [db_string get_num_open_issues_2 "select count(*) 
from ec_customer_service_issues issues, ec_user_identification id
where issues.user_identification_id = id.user_identification_id
and close_date is NULL 
and deleted_p = 'f'
$last_bit_of_query"]

if { $num_open_issues > 0 } {
    append issue_type_list_html "<tr><td align=\"right\">all others </td><td>
<a href=\"issues?view_issue_type=[ns_urlencode "all others"]\">$num_open_issues open</a> </td><td>
<a href=\"issues?view_issue_type=[ns_urlencode "all others"]&view_status=closed\">closed</a></td></tr>\n"
} else {
    append issue_type_list_html "<tr><td align=\"right\">all others </td><td>
<a href=\"issues?view_issue_type=[ns_urlencode "all others"]\">none</a> </td><td>
<a href=\"issues?view_issue_type=[ns_urlencode "all others"]&view_status=closed\">closed</a></td></tr>\n"
}

set action_url_html "[ec_acs_admin_url]users/search"
set currency [parameter::get -package_id [ec_id] -parameter Currency -default "USD"]
