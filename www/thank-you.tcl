ad_page_contract {
    @param usca_p User session begun or not

    @author
    @creation-date
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @revision-date April 2002

} {
    usca_p:optional
}

# This is a "thank you for your order" page displays order summary for
# the most recently confirmed order for this user

# We need them to be logged in

set user_id [ad_conn user_id]
if {$user_id == 0} {
    set return_url "[ad_conn url]"
    ad_returnredirect "[ad_conn package_url]register?[export_url_vars return_url]"
    ad_script_abort
}

# wtem@olywa.net, 2001-03-21
# it isn't clear to me why we would log the session here
# or why you would create a new session at this point

# User session tracking

set user_session_id [ec_get_user_session_id]
ec_create_new_session_if_necessary
ec_log_user_as_user_id_for_this_session

# Their most recently confirmed order (or the empty string if there is
# none)

set order_id [db_string  get_order_id_info "
    select order_id 
    from ec_orders 
    where user_id=:user_id 
    and confirmed_date is not null 
    and order_id = (
	select max(o2.order_id) 
	from ec_orders o2 
	where o2.user_id = $user_id 
	and o2.confirmed_date is not null)" -default ""]

if { [empty_string_p $order_id] } {
    rp_internal_redirect index
    ad_stript_abort
}

set order_summary [ec_order_summary_for_customer $order_id $user_id]
set title "Thank You For Your Order"
set context [list $title]
set ec_system_owner [ec_system_owner]

db_release_unused_handles
ad_return_template

