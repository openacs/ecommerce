#  www/ecommerce/gift-certificate-finalize-order.tcl
ad_page_contract {

 this script will:
 (1) put this order into the 'confirmed' state
 (2) try to authorize the user's credit card info and either
     (a) redirect them to a thank you page, or
     (b) redirect them to a "please fix your credit card info" page
 If they reload, we don't have to worry about the credit card
 authorization code being executed twice because the order has
 already been moved to the 'confirmed' state, which means that
 they will be redirected out of this page.
 We will redirect them to the thank you page which displays the
 order with the most recent confirmation date.
 The only potential problem is that maybe the first time the
 order got to this page it was confirmed but then execution of
 the page stopped before authorization of the order could occur.
 This problem is solved by the scheduled procedure,
 ec_query_for_cybercash_zombies, which will try to authorize
 any 'confirmed' orders over half an hour old.

    @param gift_certificate_id
    @param certificate_to
    @param certificate_from
    @param certificate_message
    @param amount
    @param recipient_email
    
    @param creditcard_number
    @param creditcard_type
    @param creditcard_expire_1
    
    @param creditcard_expire_2
    @param billing_zip_code

    @author
    @creation-date
    @cvs-id gift-certificate-finalize-order.tcl,v 3.4.6.7 2000/09/22 01:37:31 kevin Exp
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    gift_certificate_id
    certificate_to
    certificate_from
    certificate_message
    amount:notnull,float
    recipient_email:notnull,email
    
    creditcard_number:notnull
    creditcard_type:notnull
    creditcard_expire_1:notnull
    
    creditcard_expire_2:notnull
    billing_zip_code:notnull
}

ec_redirect_to_https_if_possible_and_necessary

# user must be logged in
set user_id [ad_verify_and_get_user_id]

if {$user_id == 0} {
    
    set return_url "[ad_conn url]?[export_entire_form_as_url_vars]"

    ad_returnredirect "/register?[export_url_vars return_url]"
    return
}

# first do all the usual checks

set exception_count 0
set exception_text ""


if { [string length $certificate_message] > 200 } {
    incr exception_count
    append exception_text "<li>The message you entered was too long.  It needs to contain fewer than 200 characters (the current length is [string length $certificate_message] characters)."
} elseif { [string length $certificate_to] > 100 } {
    incr exception_count
    append exception_text "<li>What you entered in the \"To\" field, $certificate_to is too long.  It needs to contain fewer than 100 characters (the current length is [string length $certificate_to] characters)."
} elseif { [string length $certificate_from] > 100 } {
    incr exception_count
    append exception_text "<li>What you entered in the \"From\" field, $certificate_from is too long.  It needs to contain fewer than 100 characters (the current length is [string length $certificate_from] characters)."
} elseif { [string length $recipient_email] > 100 } {
    incr exception_count
    append exception_text "<li>The recipient email address, $recipient_email you entered is too long.  It needs to contain fewer than 100 characters (the current length is [string length $recipient_email] characters)."
}

#  if { [regexp {[^0-9]} $amount] } {
#      incr exception_count
#      append exception_text "<li>The amount, $amount needs to be a number with no special characters."
#  } elseif
if { $amount < [util_memoize {ad_parameter -package_id [ec_id] MinGiftCertificateAmount ecommerce} [ec_cache_refresh]] } {
    incr exception_count
    append exception_text "<li>The amount, $amount needs to be at least [ec_pretty_price [util_memoize {ad_parameter -package_id [ec_id] MinGiftCertificateAmount ecommerce} [ec_cache_refresh]]]"
} elseif { $amount > [util_memoize {ad_parameter -package_id [ec_id] MaxGiftCertificateAmount ecommerce} [ec_cache_refresh]] } {
    incr exception_count
    append exception_text "<li>The amount, $amount cannot be higher than [ec_pretty_price [util_memoize {ad_parameter -package_id [ec_id] MaxGiftCertificateAmount ecommerce} [ec_cache_refresh]]]"
}

#  if {![philg_email_valid_p $recipient_email]} {
#      incr exception_count
#      append exception_text "<li>The recipient's email address that you typed doesn't look right to us.  Examples of valid email addresses are 
#  <ul>
#  <li>Alice1234@aol.com
#  <li>joe_smith@hp.com
#  <li>pierre@inria.fr
#  </ul>
#  "
#  }

if { [regexp {[^0-9]} $creditcard_number] } {
    # I've already removed spaces and dashes, so only numbers should remain
    incr exception_count
    append exception_text "<li> Your credit card number contains invalid characters."
}

# make sure the credit card type is right & that it has the right number
# of digits
# set additional_count_and_text [ec_creditcard_precheck $creditcard_number $creditcard_type]

# set exception_count [expr $exception_count + [lindex $additional_count_and_text 0]]
# append exception_text [lindex $additional_count_and_text 1]

if { $exception_count > 0 } {
    ad_return_complaint $exception_count $exception_text
    return
}

if { [empty_string_p $gift_certificate_id] } {
    ad_returnredirect "gift-certificate-order-4?[export_entire_form_as_url_vars]"
    return
}

# user session tracking
set user_session_id [ec_get_user_session_id]

ec_log_user_as_user_id_for_this_session

# doubleclick protection
if { [db_string get_gift_c_id "select count(*) from ec_gift_certificates where gift_certificate_id=:gift_certificate_id"] > 0 } {

    # query the status of the gift certificate in the database
    set gift_certificate_state [db_string get_gift_c_status "select gift_certificate_state from ec_gift_certificates where gift_certificate_id=:gift_certificate_id"]

    if { $gift_certificate_state == "authorized_plus_avs" || $gift_certificate_state == "authorized_minus_avs" } {
	set cybercash_status "success-reload"
    } elseif { $gift_certificate_state == "failed_authorization" } {
	set cybercash_status "failure-reload"
    } elseif { $gift_certificate_state == "confirmed" } {
	set cybercash_status "unknown-reload"
    } else {
	db_dml report_gc_error_into_log "insert into ec_problems_log
	(problem_id, problem_date, problem_details, gift_certificate_id)
	values
	(ec_problem_id_sequence.nextval, sysdate, 'Customer pushed reload on gift-certificate-finalize-order.tcl but gift_certificate_state wasn't authorized_plus_avs, authorized_minus_avs, failed_authorization, or confirmed',:gift_certificate_id)
	"

	ad_return_error "Unexpected Result" "We received an unexpected result when querying for the status of your gift certificate.  This problem has been logged.  However, it would be helpful if you could email <a href=\"mailto:[ad_system_owner]\">[ad_system_owner]</a> with the events that led up to this occurrence.  We apologize for this problem and we will correct it as soon as we can."
	return
    }
} else {

    # put in the credit card
    # put in the gift certificate
    # put in the transaction
    # try to auth transaction
    
    db_transaction {
    
    set creditcard_id [db_string get_cc_id "select ec_creditcard_id_sequence.nextval from dual"]


    set ccstuff_1 "[string range $creditcard_number [expr [string length $creditcard_number] -4] [expr [string length $creditcard_number] -1]]"
    set expiry "$creditcard_expire_1/$creditcard_expire_2"

db_dml get_ec_credit_card "insert into ec_creditcards
    (creditcard_id, user_id, creditcard_number, creditcard_last_four, creditcard_type, creditcard_expire, billing_zip_code)
    values
    (:creditcard_id, :user_id, :creditcard_number, :ccstuff_1, :creditcard_type,:expiry,:billing_zip_code)
    "
    
    # claim check is generated as follows:
    # 1. username of recipient (part of email address up to the @ symbol) up to 10 characters
    # 2. 10 character random string
    # 3. gift_certificate_id
    # all separated by dashes
    
    # The username is added as protection in case someone cracks the random number algorithm.
    # The gift_certificate_id is added as a guarantee of uniqueness.

    # philg_email_valid_p ensures that there will be an @ sign, thus a username will be set
    regexp {(.+)@} $recipient_email match username

    if { [string length $username] > 10 } {
	set username [string range $username 0 9]
    }

    set random_string [ec_generate_random_string 10]

    set claim_check "$username-$random_string-$gift_certificate_id"


    set peeraddr [ns_conn peeraddr]
    set gc_months [util_memoize {ad_parameter -package_id [ec_id] GiftCertificateMonths ecommerce} [ec_cache_refresh]]
    db_dml insert_new_gc_into_db  "insert into ec_gift_certificates
    (gift_certificate_id, gift_certificate_state, amount, issue_date, purchased_by, expires, claim_check, certificate_message, certificate_to, certificate_from, recipient_email, last_modified, last_modifying_user, modified_ip_address)
    values
    (:gift_certificate_id, 'confirmed', :amount, sysdate, :user_id, add_months(sysdate,:gc_months),:claim_check, :certificate_message, :certificate_to, :certificate_from, :recipient_email, sysdate, :user_id, :peeraddr)
    "
    
    set transaction_id [db_string get_transaction_id "select ec_transaction_id_sequence.nextval from dual"]
    
    db_dml insert_ec_financial_trans "insert into ec_financial_transactions
    (transaction_id, gift_certificate_id, creditcard_id, transaction_amount, transaction_type, inserted_date)
    values
    (:transaction_id, :gift_certificate_id, :creditcard_id, :amount, 'charge', sysdate)
    "
    
    }
    
    # try to authorize the transaction
    set cc_args [ns_set new]
    
    ns_set put $cc_args "amount" "[util_memoize {ad_parameter -package_id [ec_id] Currency ecommerce} [ec_cache_refresh]] $amount"
    ns_set put $cc_args "card-number" "$creditcard_number"
    ns_set put $cc_args "card-exp" "$creditcard_expire_1/$creditcard_expire_2"
    ns_set put $cc_args "card-zip" "$billing_zip_code"
    ns_set put $cc_args "order-id" "$transaction_id"
    
    set ttcc_output [ec_talk_to_cybercash "mauthonly" $cc_args]
    
    # We're interested in the txn_status, errmsg (if any) and avs_code
    set txn_status [ns_set get $ttcc_output "txn_status"]
    set errmsg [ns_set get $ttcc_output "errmsg"]
    set avs_code [ns_set get $ttcc_output "avs_code"]
    
    # If we get a txn_status of failure-q-or-cancel, it means there was a communications
    # failure and we can retry it (right away).
    
    if { [empty_string_p $txn_status] } {
	# that means we didn't hear back from CyberCash
	set cybercash_status "unknown-no-response"
    } elseif { $txn_status == "success" || $txn_status == "success-duplicate" } {
	set cybercash_status "success"
    } elseif { $txn_status == "failure-q-or-cancel" || $txn_status == "pending" } {
	# we'll retry once
	ns_log Notice "Retrying failure-q-or-cancel gift certificate # $gift_certificate_id (transaction # $transaction_id)"
	
	set cc_args [ns_set new]
	
	ns_set put $cc_args "txn-type" "auth"
	ns_set put $cc_args "order-id" "$transaction_id"
	
	set ttcc_output [ec_talk_to_cybercash "retry" $cc_args]
	set txn_status [ns_set get $ttcc_output "txn_status"]
	set errmsg [ns_set get $ttcc_output "errmsg"]
	set avs_code [ns_set get $ttcc_output "avs_code"]
	
	if {[regexp {success} $txn_status]} {
	    set cybercash_status "success"
	} else {
	    set cybercash_status "failure"
	}
    } else {
	set cybercash_status "failure"
    }
}

# Now deal with the cybercash_status:
# 1. If success, update transaction and gift certificate to authorized, 
#    send gift certificate order email, and give them a thank you page.
# 2. If failure, update gift certificate and transaction to failed,
#    create a new gift certificate_id and give them a new credit card form.
# 3. If unknown-no-response, give message saying that we didn't hear back
#    from CyberCash and that a cron job will check.
# 4. If unknown-reload, give message saying they're getting this message
#    because they pushed reload and that a cron job will check.

if { $cybercash_status == "success" || $cybercash_status == "success-reload" } {
    # we only want to make database updates and send email if the user didn't push reload
    if { $cybercash_status == "success" } {
	if { [ ec_avs_acceptable_p $avs_code ] == 1 } {
	    set cc_result "authorized_plus_avs"
	} else {
	    set cc_result "authorized_minus_avs"
	}
	
	# update transaction and gift certificate to authorized
	# setting to_be_captured_p to 't' will cause ec_unmarked_transactions to come along and mark it for capture
	db_dml update_ft_set_status "update ec_financial_transactions set authorized_date=sysdate, to_be_captured_p='t' where transaction_id=:transaction_id"
	db_dml upate_ec_gc_status "update ec_gift_certificates set authorized_date=sysdate, gift_certificate_state=:cc_result where gift_certificate_id=:gift_certificate_id"
	
	# send gift certificate order email
	ec_email_new_gift_certificate_order $gift_certificate_id
    }

    # give them a thank you page
    ad_returnredirect "gift-certificate-thank-you"
    return
    
} elseif { $cybercash_status == "failure" || $cybercash_status == "failure-reload" } {
    # we only want to make database updates if the user didn't push reload
    if { $cybercash_status == "failure" } {
	# we probably don't need to do this update of to_be_captured_p because no cron jobs
	# distinguish between null and 'f' right now, but it doesn't hurt and it might alleviate
	# someone's concern when they're looking at ec_financial_transactions and wondering
	# whether they should be concerned that failed_p is 't'
	db_dml set_ft_failure "update ec_financial_transactions set failed_p='t', to_be_captured_p='f' where transaction_id=:transaction_id"
	db_dml set_gc_failure "update ec_gift_certificates set gift_certificate_state='failed_authorization' where gift_certificate_id=:gift_certificate_id"
    }

    # give them a gift_certificate_id and a new form
    set gift_certificate_id [db_string get_cert_id_seq "select ec_gift_cert_id_sequence.nextval from dual"]
   
    set page_html "[ad_header "Credit Card Correction Needed"]
    [ec_header_image]<br clear=all>
    <blockquote>
    At this time we are unable to receive authorization to charge your
    credit card.  Please check the number and the expiration date and
    try again or use a different credit card.
    <p>
    <form method=post action=gift-certificate-finalize-order>
    [export_form_vars gift_certificate_id certificate_to certificate_from certificate_message amount recipient_email]
    <table>
    <tr>
    <td>Credit card number:</td>
    <td><input type=text name=creditcard_number size=17 value=\"$creditcard_number\"></td>
    </tr>
    <tr>
    <td>Type:</td>
    <td>[ec_creditcard_widget $creditcard_type]</td>
    </tr>
    <tr>
    <td>Expires:</td>
    <td>[ec_creditcard_expire_1_widget $creditcard_expire_1] [ec_creditcard_expire_2_widget $creditcard_expire_2]</td>
    <tr>
    <td>Billing zip code:</td>
    <td><input type=text name=billing_zip_code value=\"$billing_zip_code\" size=5></td>
    </tr>
    </table>
    <center>
    <input type=submit value=\"Continue\">
    </center>
    </form>
    </blockquote>
    [ec_footer]
    "
} elseif { $cybercash_status == "unknown-no-response" } {
    
    set page_html "[ad_header "No Response from CyberCash"]
    [ec_header_image]<br clear=all>
    <blockquote>
    We didn't receive confirmation from CyberCash about whether they were able to authorize the
    payment for your gift certificate order.
    <p>
    We will query CyberCash within the next hour to see if they processed your transaction, and
    we'll let you know by email.  We apologize for the inconvenience.
    <p>
    You can also <a href=\"gift-certificate?[export_url_vars gift_certificate_id]\">check on the status of
    this gift certificate order</a>.
    </blockquote>
    [ec_footer]
    "
} elseif { $cybercash_status == "unknown-reload" } {
    set n_seconds [db_string get_n_seconds "select round((sysdate-issue_date)*86400) as n_seconds from ec_gift_certificates where gift_certificate_id = :gift_certificate_id"]
   
    set page_html "[ad_header "Gift Certificate Order Already Processed"]
    You've probably hit submit twice from the same form.  We are already
in possession of a gift certificate order with id # $gift_certificate_id (placed $n_seconds
seconds ago) and it is being processed.  You can <a
href=\"gift-certificate?[export_url_vars gift_certificate_id]\">check on the status of
this gift certificate order</a> if you like.

    [ec_footer]
    "
}


doc_return  200 text/html $page_html
