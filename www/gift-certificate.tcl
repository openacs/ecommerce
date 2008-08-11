ad_page_contract {
    @param gift_certificate_id
    @param usca_p

    @author
    @creation-date
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @revision-date April 2002

} {
    gift_certificate_id:integer
    usca_p:optional 
}

# we need them to be logged in

set user_id [ad_conn user_id]

if {$user_id == 0} {
    
    set return_url "[ad_conn url]?[export_entire_form_as_url_vars]"

    ad_returnredirect "/register?[export_url_vars return_url]"
    ad_script_abort
}



# user session tracking
set user_session_id [ec_get_user_session_id]

ec_create_new_session_if_necessary [export_url_vars gift_certificate_id]

ec_log_user_as_user_id_for_this_session

if { [db_0or1row get_gc_info "select purchased_by, amount, recipient_email, certificate_to, certificate_from, certificate_message from ec_gift_certificates where gift_certificate_id=:gift_certificate_id"] == 0} {

    set gift_certificate_summary "Invalid Gift Certificate ID"


} else {


    if { $user_id != $purchased_by } {
	set gift_certificate_summary "Invalid Gift Certificate ID"
    } else {

	set gift_certificate_summary "
	Gift Certificate #:
	$gift_certificate_id
	<p>
	Status:
	"
	
	set status [ec_gift_certificate_status $gift_certificate_id]
	
	if { $status == "Void" || $status == "Failed Authorization" } {
	    append gift_certificate_summary "<font color=red>$status</font>"
	} else {
	    append gift_certificate_summary "$status"
	}
	
	append gift_certificate_summary "<p>
	Recipient:
	$recipient_email
	<p>
	To: $certificate_to<br>
	Amount:	[ec_pretty_price $amount]<br>
	From: $certificate_from<br>
	Message: $certificate_message
	"
    }
}

set title "Your Gift Certificate"
set context [list $title]
set ec_system_owner [ec_system_owner]
db_release_unused_handles
ad_return_template

