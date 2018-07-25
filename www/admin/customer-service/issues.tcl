# issues.tcl
ad_page_contract {
    @author
    @creation-date
    @cvs-id $Id$
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
    set order_by "issue_id"
    set order_by_sql "i.issue_id"
} else {
    switch $order_by {
        "issue_id" {
            set order_by_sql "i.issue_id"
        }
        "open_date" {
            set order_by_sql "i.open_date"
        }
        "close_date" {
            set order_by_sql "i.close_date"
        }
        "customer" {
            set order_by_sql "u.last_name, u.first_names"
        }
        "order_id" {
            set order_by_sql "i.order_id"
        }
        "issue_type" {
            set order_by_sql "m.issue_type"
        }
        default {
            set order_by_sql "i.issue_id"
        }
    }
}

set title "Issues"
set context [list [list index "Customer Service"] $title]

set export_form_vars_html [export_form_vars  view_status view_open_date order_by]

set important_issue_type_list [db_list get_issue_type_list "select picklist_item from ec_picklist_items where picklist_name='issue_type' order by sort_key"]

set issue_type_list [concat [list "uncategorized"] $important_issue_type_list [list "all others"]]

set issue_select_html ""
foreach issue_type $issue_type_list {
    if { $issue_type == $view_issue_type } {
        append issue_select_html "<option value=\"$issue_type\" selected>$issue_type</option>"
    } else {
        append issue_select_html "<option value=\"$issue_type\">$issue_type</option>"
    }
}

set status_list [list "open" "closed"]
set linked_status_list [list]
foreach status $status_list {
    if { $status == $view_status } {
        lappend linked_status_list "<b>$status</b>"
    } else {
        lappend linked_status_list "<a href=\"issues?[export_url_vars view_issue_type view_open_date order_by]&view_status=$status\">$status</a>"
    }
}
set linked_status_list_html "\[ [join $linked_status_list " | "] \]"

set open_date_list [list [list last_24 "last 24 hrs"] [list last_week "last week"] [list last_month "last month"] [list all all]]
set linked_open_date_list [list]
foreach open_date $open_date_list {
    if {$view_open_date == [lindex $open_date 0]} {
        lappend linked_open_date_list "<b>[lindex $open_date 1]</b>"
    } else {
        lappend linked_open_date_list "<a href=\"issues?[export_url_vars view_issue_type view_status order_by]&view_open_date=[lindex $open_date 0]\">[lindex $open_date 1]</a>"
    }
}
set linked_open_date_list_html "\[ [join $linked_open_date_list " | "] \]"

if { $view_status == "open" } {
    set status_query_bit "and i.close_date is null"
} else {
    set status_query_bit "and i.close_date is not null"
}
if { $view_open_date == "last_24" } {
    set open_date_query_bit [db_map last_24]
} elseif { $view_open_date == "last_week" } {
    set open_date_query_bit [db_map last_week]
} elseif { $view_open_date == "last_month" } {
    set open_date_query_bit [db_map last_month]
} else {
    set open_date_query_bit ""
}

if { $view_issue_type == "uncategorized" } {
    set sql_query [db_map uncategorized]
} elseif { $view_issue_type == "all others" } {
    if { [llength $important_issue_type_list] > 0 } {
        # taking advantage of the fact that tcl lists are just strings
        set issue_type_query_bit "and m.issue_type not in ([template::util::tcl_to_sql_list $important_issue_type_list])"
    } else {
        set issue_type_query_bit ""
    }
    set sql_query [db_map all_others]
} else {
    set sql_query [db_map default_query]
}

set link_beginning "issues.tcl?[export_url_vars view_issue_type view_status view_open_date]"

set table_header "<tr>
<td><b><a href=\"$link_beginning&order_by=[ns_urlencode "issue_id"]\">Issue ID</a></b></td>
<td><b><a href=\"$link_beginning&order_by=[ns_urlencode "open_date"]\">Open Date</a></b></td>
<td><b><a href=\"$link_beginning&order_by=[ns_urlencode "close_date"]\">Close Date</a></b></td>
<td><b><a href=\"$link_beginning&order_by=[ns_urlencode "customer"]\">Customer</a></b></td>
<td><b><a href=\"$link_beginning&order_by=[ns_urlencode "order_id"]\">Order ID</a></b></td>
<td><b><a href=\"$link_beginning&order_by=[ns_urlencode "issue_type"]\">Issue Type</a></b></td>
</tr>"

set sql $sql_query
set row_counter 0
set issues_list_html ""
db_foreach loop_through_issues $sql {
    if { $row_counter == 0 } {
        append issues_list_html $table_header
    } elseif { $row_counter == 20 } {
        append issues_list_html "</table><br><table>${table_header}"
        set row_counter 1
    }
    # even rows are white, odd are grey
    if { [expr floor($row_counter/2.)] == [expr $row_counter/2.] } {
        set bgcolor "#ffffff"
    } else {
        set bgcolor "#ececec"
    }
    append issues_list_html "<tr bgcolor=\"$bgcolor\"><td><a href=\"issue?issue_id=$issue_id\">$issue_id</a></td>
    <td>[ec_formatted_full_date $full_open_date]</td>
    <td>[ec_decode $full_close_date "" "&nbsp;" [ec_formatted_full_date $full_close_date]]</td>"
    if { ![empty_string_p $user_id] } {
        append issues_list_html "<td><a href=\"[ec_acs_admin_url]users/one?user_id=$user_id\">$users_last_name, $users_first_names</a></td>"
    } else {
        append issues_list_html "<td>unregistered user <a href=\"user-identification?[export_url_vars user_identification_id]\">$user_identification_id</a></td>"
    }
    append issues_list_html "<td>[ec_decode $order_id "" "&nbsp;" "<a href=\"../orders/one?order_id=$order_id\">$order_id</a>"]</td>"
    if { $view_issue_type =="uncategorized" } {
        append issues_list_html "<td>&nbsp;</td>"
    } else {
        append issues_list_html "<td>$issue_type</td>"
    }
    append issues_list_html "</tr>\n"
    incr row_counter
}
