# actions.tcl
ad_page_contract {
    @param view_info_used:optional
    @param view_rep:optional 
    @param view_interaction_date:optional
    @param order_by:optional
    @author
    @creation-date
    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} { 
    view_info_used:optional
    view_rep:optional 
    view_interaction_date:optional
    order_by:optional
}

ad_require_permission [ad_conn package_id] admin

if { ![info exists view_info_used] } {
    set view_info_used "none"
}
if { ![info exists view_rep] } {
    set view_rep "all"
}
if { ![info exists view_interaction_date] } {
    set view_interaction_date "all"
}
if { ![info exists order_by] } {
    set order_by "a.action_id"
}

set title  "Actions"
set context [list [list index "Customer Service"] $title]

set export_form_vars_html [export_form_vars view_interaction_date]

set important_info_used_list [db_list get_picklist_items "select picklist_item
    from ec_picklist_items
   where picklist_name='info_used' order by sort_key"]

set info_used_list [concat [list "none"] $important_info_used_list [list "all others"]]

set info_used_list_html ""
foreach info_used $info_used_list {
    if { $info_used == $view_info_used } {
        append info_used_list_html "<option value=\"${info_used}\" selected>${info_used}</option>"
    } else {
        append info_used_list_html "<option value=\"${info_used}\">${info_used}</option>"
    }
}

set sql [db_map get_customer_service_data_sql]
#set sql "
#  select i.customer_service_rep as rep, u.first_names as rep_first_names, u.last_name as rep_last_name
#    from ec_customer_serv_interactions i, cc_users u
#   where i.customer_service_rep=u.user_id
#group by i.customer_service_rep, u.first_names, u.last_name
#order by u.last_name, u.first_names
#"

set customer_service_data_html ""
db_foreach get_customer_service_data $sql {
    if { $view_rep == $rep } {
        append customer_service_data_html "<option value=$rep selected>${rep_last_name}, ${rep_first_names}</option>\n"
    } else {
        append customer_service_data_html "<option value=$rep>${rep_last_name}, ${rep_first_names}</option>\n"
    }
}

set interaction_date_list [list [list last_24 "last 24 hrs"] [list last_week "last week"] [list last_month "last month"] [list all all]]

set linked_interaction_date_list [list]
foreach interaction_date $interaction_date_list {
    if {$view_interaction_date == [lindex $interaction_date 0]} {
        lappend linked_interaction_date_list "<b>[lindex $interaction_date 1]</b>"
    } else {
        lappend linked_interaction_date_list "<a href=\"actions?[export_url_vars view_info_used view_rep order_by]&view_interaction_date=[lindex $interaction_date 0]\">[lindex $interaction_date 1]</a>"
    }
}

set set interaction_date_list_html "\[ [join $linked_interaction_date_list " | "] \]"

if { $view_rep == "all" } {
    set rep_query_bit ""
} else {
    set rep_query_bit "and i.customer_service_rep=:view_rep"
}

if { $view_interaction_date == "last_24" } {
    #set interaction_date_query_bit "and sysdate-i.interaction_date <= 1"
    set interaction_date_query_bit [db_map last_24]
} elseif { $view_interaction_date == "last_week" } {
    #set interaction_date_query_bit "and sysdate-i.interaction_date <= 7"
    set interaction_date_query_bit [db_map last_week]
} elseif { $view_interaction_date == "last_month" } {
    #set interaction_date_query_bit "and months_between(sysdate,i.interaction_date) <= 1"
    set interaction_date_query_bit [db_map last_month]
} else {
    set interaction_date_query_bit ""
}

if { $view_info_used == "none" } {
     set sql_query [db_map none_sql]
#    set sql_query "
#    select a.action_id, a.interaction_id, a.issue_id,
#           i.interaction_date, i.customer_service_rep, i.interaction_originator, i.interaction_type,
#           to_char(i.interaction_date,'YYYY-MM-DD HH24:MI:SS') as full_interaction_date,
#           reps.first_names as rep_first_names, reps.last_name as rep_last_name,
#           i.user_identification_id, customer_info.user_id as customer_user_id,
#           customer_info.first_names as customer_first_names, customer_info.last_name as customer_last_name
#      from ec_customer_service_actions a, ec_customer_serv_interactions i, cc_users reps,
#           (select id.user_identification_id, id.user_id, u2.first_names, u2.last_name
#              from ec_user_identification id, cc_users u2
#             where id.user_id=u2.user_id(+)) customer_info
#     where a.interaction_id = i.interaction_id
#       and i.user_identification_id=customer_info.user_identification_id
#       and i.customer_service_rep=reps.user_id(+)
#       and 0 = (select count(*) from ec_cs_action_info_used_map map where map.action_id=a.action_id)
#           $interaction_date_query_bit $rep_query_bit
#  order by $order_by
#    "
} elseif { $view_info_used == "all others" } {
    if { [llength $important_info_used_list] > 0 } {
        set info_used_query_bit "and map.info_used not in ([template::util::tcl_to_sql_list $important_info_used_list])"
    } else {
        set info_used_query_bit ""
    }

    set sql_query [db_map all_others_sql]
#    set sql_query "
#    select a.action_id, a.interaction_id, a.issue_id,
#           i.interaction_date, i.customer_service_rep, i.user_identification_id, i.interaction_originator, i.interaction_type,
#           to_char(i.interaction_date,'YYYY-MM-DD HH24:MI:SS') as full_interaction_date,
#           reps.first_names as rep_first_names, reps.last_name as rep_last_name,
#           customer_info.user_id as customer_user_id, customer_info.first_names as customer_first_names, customer_info.last_name as customer_last_name
#      from ec_customer_service_actions a, ec_customer_serv_interactions i, ec_cs_action_info_used_map map, cc_users reps,
#           (select id.user_identification_id, id.user_id, u2.first_names, u2.last_name
#              from ec_user_identification id, cc_users u2
#             where id.user_id=u2.user_id(+)) customer_info
#     where a.interaction_id = i.interaction_id
#       and i.user_identification_id=customer_info.user_identification_id
#       and a.action_id=map.action_id
#       and i.customer_service_rep=reps.user_id(+) $info_used_query_bit
#           $interaction_date_query_bit $rep_query_bit
#  order by $order_by
#    "
} else {

    set sql_query [db_map default_sql]
#    set sql_query "
#      select a.action_id, a.interaction_id, a.issue_id,
#             i.interaction_date, i.customer_service_rep, i.user_identification_id, i.interaction_originator, i.interaction_type,
#             to_char(i.interaction_date,'YYYY-MM-DD HH24:MI:SS') as full_interaction_date,
#             reps.first_names as rep_first_names, reps.last_name as rep_last_name,
#             customer_info.user_id as customer_user_id, customer_info.first_names as customer_first_names, customer_info.last_name as customer_last_name
#       from ec_customer_service_actions a, ec_customer_serv_interactions i, ec_cs_action_info_used_map map, cc_users reps,
#            (select id.user_identification_id, id.user_id, u2.first_names, u2.last_name
#               from ec_user_identification id, cc_users u2
#              where id.user_id=u2.user_id(+)) customer_info
#      where a.interaction_id = i.interaction_id
#        and i.user_identification_id=customer_info.user_identification_id
#        and reps.user_id=i.customer_service_rep
#        and a.action_id=map.action_id
#        and map.info_used=:view_info_used
#           $interaction_date_query_bit $rep_query_bit
#  order by $order_by
#    "
}

# set link_beginning "actions.tcl?[export_url_vars view_issue_type view_status view_open_date]"

set link_beginning "actions.tcl?[export_url_vars view_info_used view_rep view_interaction_date]"

set table_header "<tr>
<td><b><a href=\"$link_beginning&order_by=[ns_urlencode "a.action_id"]\">Action ID</a></b></td>
<td><b><a href=\"$link_beginning&order_by=[ns_urlencode "a.interaction_id"]\">Interaction ID</a></b></td>
<td><b><a href=\"$link_beginning&order_by=[ns_urlencode "a.issue_id"]\">Issue ID</a></b></td>
<td><b><a href=\"$link_beginning&order_by=[ns_urlencode "i.interaction_date"]\">Date</a></b></td>
<td><b><a href=\"$link_beginning&order_by=[ns_urlencode "customer_last_name, customer_first_names"]\">Customer</a></b></td>
<td><b><a href=\"$link_beginning&order_by=[ns_urlencode "rep_last_name, rep_first_names"]\">Rep</a></b></td>
<td><b><a href=\"$link_beginning&order_by=[ns_urlencode "i.interaction_originator"]\">Originator</a></b></td>
<td><b><a href=\"$link_beginning&order_by=[ns_urlencode "i.interaction_type"]\">Interaction Type</a></b></td>
</tr>"

set sql $sql_query
set row_counter 0
set interaction_info_maybe_rep_html ""
db_foreach get_interaction_info_maybe_rep $sql {
    if { $row_counter == 0 } {
        append interaction_info_maybe_rep_html $table_header
    } elseif { $row_counter == 20 } {
        append interaction_info_maybe_rep_html "</table><br><table>${table_header}"
        set row_counter 1
    }
    # even rows are white, odd are grey
    if { [expr floor($row_counter/2.)] == [expr $row_counter/2.] } {
        set bgcolor "#ffffff"
    } else {
        set bgcolor "#ececec"
    }
    append interaction_info_maybe_rep_html "<tr bgcolor=\"$bgcolor\"><td>$action_id</td><td><a href=\"interaction?[export_url_vars interaction_id]\">$interaction_id</a></td><td><a href=\"issue?[export_url_vars issue_id]\">$issue_id</a></td><td>[ec_formatted_full_date $full_interaction_date]</td>"
    if { [empty_string_p $customer_user_id] } {
        append interaction_info_maybe_rep_html "<td>unregistered user <a href=\"user-identification?[export_url_vars user_identification_id]\">$user_identification_id</a></td>"
    } else {
        append interaction_info_maybe_rep_html "<td><a href=\"[ec_acs_admin_url]users/one?user_id=$customer_user_id\">$customer_last_name, $customer_first_names</a></td>"
    }
    if { ![empty_string_p $customer_service_rep] } {
        append interaction_info_maybe_rep_html "<td><a href=\"[ec_acs_admin_url]users/one?user_id=$customer_service_rep\">$rep_last_name, $rep_first_names</a></td>"
    } else {
        append interaction_info_maybe_rep_html "<td>&nbsp;</td>"
    }
    append interaction_info_maybe_rep_html "<td>$interaction_originator</td><td>$interaction_type</td></tr>\n"
    incr row_counter
}

