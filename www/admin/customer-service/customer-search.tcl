# customer-search.tcl

ad_page_contract {  
    @param amount:optional
    @param days:optional
    @author
    @creation-date
    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} { 
    amount:optional
    days:optional
}

ad_require_permission [ad_conn package_id] admin

# error checking
set exception_count 0
set exception_text ""

if { ![info exists amount] || [empty_string_p $amount] } {
    incr exception_count
    append exception_text "<li>You forgot to enter the amount."
} elseif { [regexp {[^0-9\.]} $amount] } {
    incr exception_count
    append exception_text "<li>The amount must be a number (no special characters)."
}

if { ![info exists days] || [empty_string_p $days] } {
    incr exception_count
    append exception_text "<li>You forgot to enter the number of days."
} elseif { [regexp {[^0-9\.]} $days] } {
    incr exception_count
    append exception_text "<li>The number of days must be a number (no special characters)."
}

if { $exception_count > 0 } {
    ad_return_complaint $exception_count $exception_text
    return
}

set title  "Customer Search"
set context [list [list index "Customer Service"] $title]

set currency [ec_pretty_price $amount [parameter::get -package_id [ec_id] -parameter Currency -default "USD"]]

#set sql "select unique o.user_id, u.first_names, u.last_name, u.email
#from ec_orders o, cc_users u
#where o.user_id=u.user_id
#and o.order_state not in ('void','in_basket')
#and sysdate - o.confirmed_date <= :days
#and :amount <= (select sum(i.price_charged) from ec_items i where i.order_id=o.order_id and (i.item_state is null or i.item_state not in ('void','received_back')))
#"
set sql [db_map user_id_sql]

set user_id_list [list]
set user_ids_from_search_html ""
db_foreach get_user_ids_from_search $sql {
    append user_ids_from_search_html "<li><a href=\"[ec_acs_admin_url]users/one?user_id=$user_id\">$first_names $last_name</a> ($email)</li>"
    lappend user_id_list $user_id
}
set user_id_list_len [llength $user_id_list]

set export_url_vars_html [export_url_vars user_id_list]

db_release_unused_handles
