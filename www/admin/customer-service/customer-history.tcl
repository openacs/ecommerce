# customer-history.tcl
# was interactions.tcl

ad_page_contract {   
    @param customer_type (user_identification_id or user_id)
    @param customer_id  (value of user_id or user_identification_id)
    @param view_rep:optional
    @param view_interaction_originator:optional
    @param view_interaction_type:optional
    @param view_interaction_date:optional
    @author Torben Brosten torben@kappacorp.com
    @creation-date 2004-09-11
} {
    customer_type:notnull
    customer_id:integer
    view_rep:optional
    view_interaction_originator:optional
    view_interaction_type:optional
    view_interaction_date:optional
}

ad_require_permission [ad_conn package_id] admin

if { ![info exists view_rep] } {
    set view_rep "all"
}
if { ![info exists view_interaction_originator] } {
    set view_interaction_originator "all"
}
if { ![info exists view_interaction_type] } {
    set view_interaction_type "all"
}
if { ![info exists view_interaction_date] } {
    set view_interaction_date "all"
}
if { ![info exists order_by] } {
    set order_by "interaction_id"
}

if {$customer_type == "user_id" && [db_0or1row check_customer "select user_identification_id from ec_user_identification where user_id=:customer_id"] == 0} {
    ad_returnredirect "[ec_acs_admin_url]users/one?user_id=$customer_id"
}

set title  "Customer History"
set context [list [list index "Customer Service"] $title]

set export_form_vars_html [export_form_vars view_interaction_originator view_interaction_type view_interaction_date order_by]



set sql [db_map get_rep_info_by_rep_sql]
#set sql "select i.customer_service_rep as rep, u.first_names as rep_first_names, u.last_name as rep_last_name from ec_customer_serv_interactions i, cc_users u where i.customer_service_rep=u.user_id
#group by i.customer_service_rep, u.first_names, u.last_name order by u.last_name, u.first_names"
set rep_info_by_rep_html "<option value=\"all\">All</option>"
db_foreach get_rep_info_by_rep $sql {
    if { $view_rep == $rep } {
        append rep_info_by_rep_html "<option value=$rep selected>$rep_last_name, $rep_first_names</option>\n"
    } else {
        append rep_info_by_rep_html "<option value=$rep>$rep_last_name, $rep_first_names</option>\n"
    }
}

set interaction_originator_list [db_list get_interation_originator_list "select unique interaction_originator from ec_customer_serv_interactions"]
lappend interaction_originator_list "all"
set linked_interaction_originator_list [list]

foreach interaction_originator $interaction_originator_list {
    if { $interaction_originator == $view_interaction_originator } {
        lappend linked_interaction_originator_list "<b>$interaction_originator</b>"
    } else {
        lappend linked_interaction_originator_list "<a href=\"customer-history?[export_url_vars customer_type customer_id view_rep view_interaction_type view_interaction_date]&view_interaction_originator=[ns_urlencode $interaction_originator]\">$interaction_originator</a>"
    }
}
set interaction_originator_html "\[ [join $linked_interaction_originator_list " | "] \]"

set interaction_type_list [db_list get_interaction_type_list "select picklist_item from ec_picklist_items where picklist_name='interaction_type' order by sort_key"]
lappend interaction_type_list "all"
foreach interaction_type $interaction_type_list {
    if { $interaction_type == $view_interaction_type } {
        lappend linked_interaction_type_list "<b>$interaction_type</b>"
    } else {
        lappend linked_interaction_type_list "<a href=\"customer-history?[export_url_vars customer_type customer_id view_rep view_interaction_originator view_interaction_date]&view_interaction_type=[ns_urlencode $interaction_type]\">$interaction_type</a>"
    }
}
set interaction_type_list_html "\[ [join $linked_interaction_type_list " | "] \]"

set interaction_date_list [list [list last_24 "last 24 hrs"] [list last_week "last week"] [list last_month "last month"] [list all all]]
set linked_interaction_date_list [list]
foreach interaction_date $interaction_date_list {
    if {$view_interaction_date == [lindex $interaction_date 0]} {
        lappend linked_interaction_date_list "<b>[lindex $interaction_date 1]</b>"
    } else {
        lappend linked_interaction_date_list "<a href=\"customer-history?[export_url_vars customer_type customer_id view_issue_type view_status order_by]&view_interaction_date=[lindex $interaction_date 0]\">[lindex $interaction_date 1]</a>"
    }
}
set interaction_date_list_html "\[ [join $linked_interaction_date_list " | "] \]"

if {$customer_type == "user_identification_id"} {
    set customer_query_bit "and i.user_identification_id=:customer_id"
} else {
    set customer_query_bit "and i.user_id=:customer_id"
}
if { $view_rep == "all" } {
    set rep_query_bit ""
} else {
    set rep_query_bit "and i.customer_service_rep=:view_rep"
}
if { $view_interaction_originator == "all" } {
    set interaction_originator_query_bit ""
} else {
    set interaction_originator_query_bit "and i.interaction_originator=:view_interaction_originator"
}
if { $view_interaction_type == "all" } {
    set interaction_type_query_bit ""
} else {
    set interaction_type_query_bit "and i.interaction_type=:view_interaction_type"
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

set link_beginning "customer-history.tcl?[export_url_vars customer_type customer_id view_rep view_interaction_originator view_interaction_type view_interaction_date]"

set table_header "<tr><td><b><a href=\"$link_beginning&order_by=[ns_urlencode "i.interaction_id"]\">Interaction ID</a></b></td>
<td><b><a href=\"$link_beginning&order_by=[ns_urlencode "i.interaction_date"]\">Date</a></b></td>
<td><b><a href=\"$link_beginning&order_by=[ns_urlencode "rep_last_name, rep_first_names"]\">Rep</a></b></td>
<td><b><a href=\"$link_beginning&order_by=[ns_urlencode "customer_last_name, customer_first_names"]\">Customer</a></b></td>
<td><b><a href=\"$link_beginning&order_by=[ns_urlencode "i.interaction_originator"]\">Originator</a></b></td>
<td><b><a href=\"$link_beginning&order_by=[ns_urlencode "i.interaction_type"]\">Type</a></b></td></tr>\n"

#set sql "select i.interaction_id, i.customer_service_rep, i.interaction_date,
#to_char(i.interaction_date,'YYYY-MM-DD HH24:MI:SS') as full_interaction_date, i.interaction_originator,
#i.interaction_type, i.user_identification_id, reps.first_names as rep_first_names,
#reps.last_name as rep_last_name, customer_info.user_identification_id,
#customer_info.user_id as customer_user_id, customer_info.first_names as customer_first_names,
#customer_info.last_name as customer_last_name
#from ec_customer_serv_interactions i, cc_users reps, 
#(select id.user_identification_id, id.user_id, u2.first_names, u2.last_name from ec_user_identification id, cc_users u2 where id.user_id=u2.user_id(+)) customer_info
#where i.customer_service_rep=reps.user_id(+)
#and i.user_identification_id=customer_info.user_identification_id
#$rep_query_bit $interaction_originator_query_bit $interaction_type_query_bit $interaction_date_query_bit
#order by $order_by"

set sql [db_map get_customer_interaction_detail_sql]
set row_counter 0
set customer_interaction_detail_html ""
db_foreach get_customer_interaction_detail $sql {
    if { $row_counter == 0 } {
        append customer_interaction_detail_html $table_header
    } elseif { $row_counter == 20 } {
        append customer_interaction_detail_html "</table><br><table>${table_header}"
        set row_counter 1
    }
    # even rows are white, odd are grey
    if { [expr floor($row_counter/2.)] == [expr $row_counter/2.] } {
        set bgcolor "#ffffff"
    } else {
        set bgcolor "#ececec"
    }
    append customer_interaction_detail_html "<tr bgcolor=\"$bgcolor\"><td><a href=\"customer-history?customer_type=$customer_type&customer_id=${customer_id}&interaction_id=$interaction_id\">$interaction_id</a></td><td>[ec_formatted_full_date $full_interaction_date]</td>"
    if { ![empty_string_p $customer_service_rep] } {
        append customer_interaction_detail_html "<td><a href=\"[ec_acs_admin_url]users/one?user_id=$customer_service_rep\">$rep_last_name, $rep_first_names</a></td>"
    } else {
        append customer_interaction_detail_html "<td>&nbsp;</td>"
    }
    if { ![empty_string_p $customer_user_id] } {
        append customer_interaction_detail_html "<td><a href=\"[ec_acs_admin_url]users/one?user_id=$customer_user_id\">$customer_last_name, $customer_first_names</a></td>"
    } else {
        append customer_interaction_detail_html "<td>unregistered user: <a href=\"user-identification?[export_url_vars user_identification_id]\">$user_identification_id</a></td>"
    }
    append customer_interaction_detail_html "<td>$interaction_originator</td><td>$interaction_type</td></tr>\n"
    incr row_counter
}

