# customer-search.tcl

ad_page_contract {  
    @param amount:optional
    @param days:optional
    @author
    @creation-date
    @cvs-id customer-search.tcl,v 3.2.2.3 2000/09/22 01:34:51 kevin Exp
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


append doc_body "[ad_admin_header "Customer Search"]

<h2>Customer Search</h2>

[ad_admin_context_bar [list "../index.tcl" "Ecommerce([ec_system_name])"] [list "index.tcl" "Customer Service Administration"] "Customer Search"]

<hr>
Customers who spent more than [ec_pretty_price $amount [util_memoize {ad_parameter -package_id [ec_id] Currency ecommerce} [ec_cache_refresh]]] in the last $days days:
<ul>
"



set sql "select unique o.user_id, u.first_names, u.last_name, u.email
from ec_orders o, cc_users u
where o.user_id=u.user_id
and o.order_state not in ('void','in_basket')
and sysdate - o.confirmed_date <= :days
and :amount <= (select sum(i.price_charged) from ec_items i where i.order_id=o.order_id and (i.item_state is null or i.item_state not in ('void','received_back')))
"

set user_id_list [list]
db_foreach get_user_ids_from_search $sql {
    
    append doc_body "<li><a href=\"[ec_acs_admin_url]users/one?user_id=$user_id\">$first_names $last_name</a> ($email)"
    lappend user_id_list $user_id
}

if { [llength $user_id_list] == 0 } {
    append doc_body "None found."
} 

append doc_body "</ul>
"

if { [llength $user_id_list] != 0 } {
    append doc_body "<a href=\"spam-2?show_users_p=t&[export_url_vars user_id_list]\">Spam these users</a>"
}

append doc_body "[ad_admin_footer]
"

db_release_unused_handles

doc_return 200 text/html $doc_body