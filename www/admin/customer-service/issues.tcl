# issues.tcl

ad_page_contract {
    @author
    @creation-date
    @cvs-id issues.tcl,v 3.2.2.5 2000/09/22 01:34:53 kevin Exp
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    view_issue_type:optional
    view_status:optional
    view_open_date:optional
    order_by:optional
}

ad_require_permission [ad_conn package_id] admin

if { ![info exists view_issue_type] } {
    set view_issue_type "uncategorized"
}
if { ![info exists view_status] } {
    set view_status "open"
}
if { ![info exists view_open_date] } {
    set view_open_date "all"
}
if { ![info exists order_by] } {
    set order_by "i.issue_id"
}



append doc_body "[ad_admin_header "Customer Service Issues"]

<h2>Customer Service Issues</h2>

[ad_admin_context_bar [list "../index.tcl" "Ecommerce([ec_system_name])"] [list "index.tcl" "Customer Service Administration"] "Issues"]

<hr>

<form method=post action=issues>
[export_form_vars  view_status view_open_date order_by]

<table border=0 cellspacing=0 cellpadding=0 width=100%>
<tr bgcolor=ececec>
<td align=center><b>Issue Type</b></td>
<td align=center><b>Status</b></td>
<td align=center><b>Open Date</b></td>
</tr>
<tr>
<td align=center><select name=view_issue_type>
"



set important_issue_type_list [db_list get_issue_type_list "select picklist_item from ec_picklist_items where picklist_name='issue_type' order by sort_key"]

set issue_type_list [concat [list "uncategorized"] $important_issue_type_list [list "all others"]]

foreach issue_type $issue_type_list {
    if { $issue_type == $view_issue_type } {
	append doc_body "<option value=\"$issue_type\" selected>$issue_type"
    } else {
	append doc_body "<option value=\"$issue_type\">$issue_type"
    }
}
append doc_body "</select>
<input type=submit value=\"Change\">
</td>
<td align=center>
"

set status_list [list "open" "closed"]

set linked_status_list [list]

foreach status $status_list {
    if { $status == $view_status } {
	lappend linked_status_list "<b>$status</b>"
    } else {
	lappend linked_status_list "<a href=\"issues?[export_url_vars view_issue_type view_open_date order_by]&view_status=$status\">$status</a>"
    }
}

append doc_body "\[ [join $linked_status_list " | "] \]
</td>
<td align=center>
"

set open_date_list [list [list last_24 "last 24 hrs"] [list last_week "last week"] [list last_month "last month"] [list all all]]

set linked_open_date_list [list]

foreach open_date $open_date_list {
    if {$view_open_date == [lindex $open_date 0]} {
	lappend linked_open_date_list "<b>[lindex $open_date 1]</b>"
    } else {
	lappend linked_open_date_list "<a href=\"issues?[export_url_vars view_issue_type view_status order_by]&view_open_date=[lindex $open_date 0]\">[lindex $open_date 1]</a>"
    }
}

append doc_body "\[ [join $linked_open_date_list " | "] \]

</td></tr></table>

</form>
<blockquote>
"

if { $view_status == "open" } {
    set status_query_bit "and i.close_date is null"
} else {
    set status_query_bit "and i.close_date is not null"
}

if { $view_open_date == "last_24" } {
    set open_date_query_bit "and sysdate-i.open_date <= 1"
} elseif { $view_open_date == "last_week" } {
    set open_date_query_bit "and sysdate-i.open_date <= 7"
} elseif { $view_open_date == "last_month" } {
    set open_date_query_bit "and months_between(sysdate,i.open_date) <= 1"
} else {
    set open_date_query_bit ""
}

if { $view_issue_type == "uncategorized" } {

    set sql_query "select i.issue_id, u.user_id, u.first_names as users_first_names,
    u.last_name as users_last_name, id.user_identification_id, i.order_id,
    to_char(open_date,'YYYY-MM-DD HH24:MI:SS') as full_open_date,
    to_char(close_date,'YYYY-MM-DD HH24:MI:SS') as full_close_date
    from ec_customer_service_issues i, cc_users u, ec_user_identification id
    where i.user_identification_id = id.user_identification_id
    and id.user_id = u.user_id(+)
    and 0 = (select count(*) from ec_cs_issue_type_map m where m.issue_id=i.issue_id)
    $open_date_query_bit $status_query_bit
    order by i.issue_id desc
    "

} elseif { $view_issue_type == "all others" } {
    
    if { [llength $important_issue_type_list] > 0 } {
	# taking advantage of the fact that tcl lists are just strings
	set safe_important_issue_type_list [DoubleApos $important_issue_type_list]
	set issue_type_query_bit "and m.issue_type not in ('[join $safe_important_issue_type_list "', '"]')"
    } else {
	set issue_type_query_bit ""
    }

    set sql_query "select i.issue_id, u.user_id, u.first_names as users_first_names, 
    u.last_name as users_last_name, id.user_identification_id, i.order_id,
    to_char(open_date,'YYYY-MM-DD HH24:MI:SS') as full_open_date,
    to_char(close_date,'YYYY-MM-DD HH24:MI:SS') as full_close_date,
    m.issue_type
    from ec_customer_service_issues i, cc_users u, ec_user_identification id, ec_cs_issue_type_map m
    where i.user_identification_id = id.user_identification_id
    and id.user_id = u.user_id (+)
    and i.issue_id = m.issue_id
    $open_date_query_bit $status_query_bit
    $issue_type_query_bit
    order by :order_by
    "

} else {

    set sql_query "select i.issue_id, u.user_id, u.first_names as users_first_names, 
    u.last_name as users_last_name, id.user_identification_id, i.order_id,
    to_char(open_date,'YYYY-MM-DD HH24:MI:SS') as full_open_date,
    to_char(close_date,'YYYY-MM-DD HH24:MI:SS') as full_close_date,
    m.issue_type
    from ec_customer_service_issues i, cc_users u, ec_user_identification id, ec_cs_issue_type_map m
    where i.user_identification_id = id.user_identification_id
    and id.user_id = u.user_id (+)
    and i.issue_id = m.issue_id
    and m.issue_type=:view_issue_type
    $open_date_query_bit $status_query_bit
    order by :order_by
    "
}

set link_beginning "issues.tcl?[export_url_vars view_issue_type view_status view_open_date]"

set table_header "<table>
<tr>
<td><b><a href=\"$link_beginning&order_by=[ns_urlencode "i.issue_id"]\">Issue ID</a></b></td>
<td><b><a href=\"$link_beginning&order_by=[ns_urlencode "i.open_date"]\">Open Date</a></b></td>
<td><b><a href=\"$link_beginning&order_by=[ns_urlencode "i.close_date"]\">Close Date</a></b></td>
<td><b><a href=\"$link_beginning&order_by=[ns_urlencode "u.last_name, u.first_names"]\">Customer</a></b></td>
<td><b><a href=\"$link_beginning&order_by=[ns_urlencode "i.order_id"]\">Order ID</a></b></td>
<td><b><a href=\"$link_beginning&order_by=[ns_urlencode "m.issue_type"]\">Issue Type</a></b></td>
</tr>"

set sql $sql_query

set row_counter 0
db_foreach loop_through_issues $sql {
    
    if { $row_counter == 0 } {
	append doc_body $table_header
    } elseif { $row_counter == 20 } {
	append doc_body "</table>
	<p>
	$table_header
	"
	set row_counter 1
    }
    # even rows are white, odd are grey
    if { [expr floor($row_counter/2.)] == [expr $row_counter/2.] } {
	set bgcolor "white"
    } else {
	set bgcolor "ececec"
    }

    append doc_body "<tr bgcolor=\"$bgcolor\"><td><a href=\"issue?issue_id=$issue_id\">$issue_id</a></td>
    <td>[ec_formatted_full_date $full_open_date]</td>
    <td>[ec_decode $full_close_date "" "&nbsp;" [ec_formatted_full_date $full_close_date]]</td>
    "

    if { ![empty_string_p $user_id] } {
	append doc_body "<td><a href=\"[ec_acs_admin_url]users/one?user_id=$user_id\">$users_last_name, $users_first_names</a></td>"
    } else {
	append doc_body "<td>unregistered user <a href=\"user-identification?[export_url_vars user_identification_id]\">$user_identification_id</a></td>"
    }

    append doc_body "<td>[ec_decode $order_id "" "&nbsp;" "<a href=\"../orders/one?order_id=$order_id\">$order_id</a>"]</td>"

    if { $view_issue_type =="uncategorized" } {
	append doc_body "<td>&nbsp;</td>"
    } else {
	append doc_body "<td>$issue_type</td>"
    }

    append doc_body "</tr>"
    incr row_counter
}

if { $row_counter != 0 } {
    append doc_body "</table>"
} else {
    append doc_body "<center>None Found</center>"
}

append doc_body "
</blockquote>
[ad_admin_footer]
"



doc_return  200 text/html $doc_body
