# index.tcl

ad_page_contract {
    @author
    @creation-date
    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
}
# 
ad_require_permission [ad_conn package_id] admin

append doc_body "[ad_admin_header "Customer Service Administration"]

<h2>Customer Service Issues</h2>

[ad_context_bar [list "../index.tcl" "Ecommerce([ec_system_name])"] "Customer Service"]

<hr noshade>


<table border=\"0\" cellspacing=\"0\" cellpadding=\"2\" bgcolor=\"\#cccccc\" align=\"right\">
<tr><td><p>type</p></td><td><p>open</p></td><td><p> closed</p></td></tr>
<tr><td align=\"right\">uncategorized </td><td>
"

set num_open_issues [db_string get_open_issues "select count(*) 
from ec_customer_service_issues issues, ec_user_identification id
where issues.user_identification_id = id.user_identification_id
and close_date is NULL 
and deleted_p = 'f'
and 0 = (select count(*) from ec_cs_issue_type_map map where map.issue_id=issues.issue_id)"]

if {$num_open_issues > 0 } {
    append doc_body "<a href=\"issues\">$num_open_issues open</a> </td><td><a href=\"issues?view_status=closed\">closed</a></td></tr>"
} else {
    append doc_body "<a href=\"issues\">none</a></td><td><a href=\"issues?view_status=closed\">closed</a></td></tr>"
}

# only want to show issue types in the issue type widget, and then clump all others under
# "other"
set issue_type_list [db_list get_issue_type_list "select picklist_item from ec_picklist_items where picklist_name='issue_type' order by sort_key"]

foreach issue_type $issue_type_list {

    set num_open_issues [db_string get_open_issues_of_type "select count(*) 
from ec_customer_service_issues issues, ec_user_identification id
where issues.user_identification_id = id.user_identification_id
and close_date is NULL 
and deleted_p = 'f'
and 1 <= (select count(*) from ec_cs_issue_type_map map where map.issue_id=issues.issue_id and map.issue_type=:issue_type)"]

if {$num_open_issues > 0 } {
    append doc_body "<tr><td align=\"right\">$issue_type </td><td> 
<a href=\"issues?view_issue_type=[ns_urlencode $issue_type]\">$num_open_issues open</a> </td><td> <a href=\"issues?view_issue_type=[ns_urlencode $issue_type]&view_status=closed\">closed</a>
</td></tr>"
} else {
    append doc_body "<tr><td align=\"right\">$issue_type </td><td> 
<a href=\"issues?view_issue_type=[ns_urlencode $issue_type]\">none</a></td><td> <a href=\"issues?view_issue_type=[ns_urlencode $issue_type]&view_status=closed\">closed</a>
</td></tr>"
}


}

# same query for issues that aren't in issue_type_list

if { [llength $issue_type_list] > 0 } {
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
    append doc_body "<tr><td align=\"right\">all others </td><td>
<a href=\"issues?view_issue_type=[ns_urlencode "all others"]\">$num_open_issues open</a> </td><td>
<a href=\"issues?view_issue_type=[ns_urlencode "all others"]&view_status=closed\">closed</a>"
} else {
    append doc_body "<tr><td align=\"right\">all others </td><td>
<a href=\"issues?view_issue_type=[ns_urlencode "all others"]\">none</a> </td><td>
<a href=\"issues?view_issue_type=[ns_urlencode "all others"]&view_status=closed\">closed</a>"
}
append doc_body "</table><p>add <a href=\"interaction-add\">New Interaction</a></p>"

if { [llength $issue_type_list] == 0 } {
    append doc_body "<p>If you want to see issues separated out by commonly used issue types, then add those issue types to the issue type in <a href=\"picklists\">Picklist Management</a>.</p>" 
}

append doc_body "<h3>Search for customer</h3>

<FORM METHOD=get ACTION=[ec_acs_admin_url]users/search>
<input type=hidden name=target value=\"one.tcl\">
<tr><td>Search for <b>registered</b> users: <input type=text size=15 name=keyword>
</FORM>

<form method=post action=user-identification-search>
<tr><td>Search for <b>unregistered</b> users with a customer service history:
<input type=text size=15 name=keyword>
</form>

<form method=post action=customer-search>
<tr><td>Customers who have spent over
<input type=text size=5 name=amount>
([ad_parameter -package_id [ec_id] Currency ecommerce])
in the last <input type=text size=2 name=days> days.
<input type=submit value=\"Go\">
</form>


<h3>Administrative Actions</h3>

<ul>
<!---
<tr><td><a href=\"spam\">Spam Users</a>
<tr><td><a href=\"picklists\">Picklist Management</a>
<tr><td><a href=\"canned-responses\">Canned Responses</a>
--->

<tr><td><a href=\"statistics\">Statistics and Reports</a>
</ul>

[ad_admin_footer]
"



doc_return  200 text/html $doc_body

