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

<h2>Customer Service Administration</h2>

[ad_admin_context_bar [list "../index.tcl" "Ecommerce([ec_system_name])"] "Customer Service Administration"]

<hr>

<ul>
<li>Insert <a href=\"interaction-add\">New Interaction</a>
</ul>

<h3>Customer Service Issues</h3>

<ul>
<b><li>uncategorized</b> :
"



set num_open_issues [db_string get_open_issues "select count(*) 
from ec_customer_service_issues issues, ec_user_identification id
where issues.user_identification_id = id.user_identification_id
and close_date is NULL 
and deleted_p = 'f'
and 0 = (select count(*) from ec_cs_issue_type_map map where map.issue_id=issues.issue_id)"]

append doc_body "<a href=\"issues\">open</a> <font size=-1>($num_open_issues)</font> | 
<a href=\"issues?view_status=closed\">closed</a>

<p>
"

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

append doc_body "<b><li>$issue_type</b> : 

<a href=\"issues?view_issue_type=[ns_urlencode $issue_type]\">open</a> <font size=-1>($num_open_issues)</font> | <a href=\"issues?view_issue_type=[ns_urlencode $issue_type]&view_status=closed\">closed</a>

<p>
"

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

append doc_body "<b><li>all others</b> :
<a href=\"issues?view_issue_type=[ns_urlencode "all others"]\">open</a> <font size=-1>($num_open_issues)</font> |
<a href=\"issues?view_issue_type=[ns_urlencode "all others"]&view_status=closed\">closed</a>
</ul>
<p>
"

if { [llength $issue_type_list] == 0 } {
    append doc_body "<b>If you want to see issues separated out by commonly used issue types, then add those issue types to the issue type picklist below in Picklist Management.</b>" 
}

append doc_body "</ul>
<p>

<h3>Customers</h3>

<ul>
<FORM METHOD=get ACTION=[ec_acs_admin_url]users/search>
<input type=hidden name=target value=\"one.tcl\">
<li>Quick search for registered users: <input type=text size=15 name=keyword>
</FORM>

<p>

<form method=post action=user-identification-search>
<li>Quick search for unregistered users with a customer service history:
<input type=text size=15 name=keyword>
</form>

<p>

<form method=post action=customer-search>
<li>Customers who have spent over
<input type=text size=5 name=amount>
([ad_parameter -package_id [ec_id] Currency ecommerce])
in the last <input type=text size=2 name=days> days
<input type=submit value=\"Go\">
</form>
</ul>

<h3>Administrative Actions</h3>

<ul>
<li><a href=\"spam\">Spam Users</a>
<li><a href=\"picklists\">Picklist Management</a>
<li><a href=\"canned-responses\">Canned Responses</a>

<p>

<li><a href=\"statistics\">Statistics and Reports</a>
</ul>

[ad_admin_footer]
"



doc_return  200 text/html $doc_body

