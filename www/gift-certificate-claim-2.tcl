ad_page_contract {
    @param claim_check the string used to claim the certificate 

    @author
    @creation-date
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @revision-date April 2002

} {
    claim_check:notnull
    address_id:notnull
}

# we need them to be logged in
set user_id [ad_conn user_id]

if {$user_id == 0} {
    set return_url "[ad_conn url]?[export_entire_form_as_url_vars]"
    ad_returnredirect "/register?[export_url_vars return_url]"
    ad_script_abort
}

# Make sure they have an in_basket order and a user_session_id; this
# will make it more annoying for someone who just wants to come to
# this page and try random number after random number

set user_session_id [ec_get_user_session_id]
if { $user_session_id == 0 } {
    rp_internal_redirect "index"
    ad_script_abort
}

set order_id [db_string get_order_id "
     select order_id 
     from ec_orders 
     where user_session_id = :user_session_id 
     and order_state='in_basket'" -default ""]
if { [empty_string_p $order_id] } {
    rp_internal_redirect "index"
    ad_script_abort
}

# See if there's a gift certificate with that claim check

set gift_certificate_id [db_string get_gc_id "
    select gift_certificate_id 
    from ec_gift_certificates 
    where claim_check=:claim_check" -default ""]
if { [empty_string_p $gift_certificate_id] } {
    ad_return_complaint 1 "
	<p>The claim check you have entered is invalid.  Please re-check it.</p>
	<p>The claim check is case sensitive; enter it exactly as shown on your gift certificate.</p>"
    set prob_details "
	Incorrect gift certificate claim check entered at [ad_conn url].
	Claim check entered: $claim_check by user ID: $user_id.
	They may have just made a typo but if this happens repeatedly from the same IP address ([ns_conn peeraddr]) you may wish to look into this."
    db_dml insert_error_failed_gc_claim "
	insert into ec_problems_log
    	(problem_id, problem_date, problem_details)
    	values
    	(ec_problem_id_sequence.nextval, sysdate,:prob_details )"
    ad_script_abort
}

# There is a gift certificate with that claim check;
# now check whether it's already been claimed
# and, if so, whether it was claimed by this user

se title "Completing Your Order"
set ec_system_owner [ec_system_owner]

db_1row get_gc_user_id "
    select user_id as gift_certificate_user_id, amount 
    from ec_gift_certificates 
    where gift_certificate_id = :gift_certificate_id"

if { [empty_string_p $gift_certificate_user_id ] } {

    # Then no one has claimed it, so go ahead and assign it to them

    db_dml update_ec_cert_set_user "
	update ec_gift_certificates 
	set user_id=:user_id, claimed_date = sysdate 
	where gift_certificate_id = :gift_certificate_id"
    set title "Gift Certificate Claimed"
    set certificate_added_p "true"
} else {

    # It's already been claimed. See if it was claimed by a different
    # user and, if so, record the problem

    if { $user_id != $gift_certificate_user_id } {

	set prob_details "
	    User ID $user_id tried to claim gift certificate $gift_certificate_id at [ad_conn url], but it had already been claimed by User ID $gift_certificate_id."
	
	db_dml insert_other_claim_prob "
	    insert into ec_problems_log
	    (problem_id, problem_date, gift_certificate_id, problem_details)
	    values
	    (ec_problem_id_sequence.nextval, sysdate, :gift_certificate_id, :prob_details)"
    }

    set title "Gift Certificate Already Claimed"
    set certificate_added_p "false"
    db_release_unused_handles
}
set context [list $title]
