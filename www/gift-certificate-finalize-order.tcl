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
    ec_query_for_payment_zombies, which will try to authorize
    any 'confirmed' orders over half an hour old.

    @param address_id
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

    @author
    @creation-date
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse <bart.teeuwisse@7-sisters.com>
    @revision-date March 2002

} {
    address_id
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
}

ec_redirect_to_https_if_possible_and_necessary

# User must be logged in

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
    append exception_text "
	<li>
	  The message you entered was too long. 
	  It needs to contain fewer than 200 characters (the current length is [string length $certificate_message] characters).
	</li>"
} elseif { [string length $certificate_to] > 100 } {
    incr exception_count
    append exception_text "
	<li>
	  What you entered in the \"To\" field, $certificate_to is too long. 
	  It needs to contain fewer than 100 characters (the current length is [string length $certificate_to] characters).
	</li>"
} elseif { [string length $certificate_from] > 100 } {
    incr exception_count
    append exception_text "
	<li>
	  What you entered in the \"From\" field, $certificate_from is too long.
	  It needs to contain fewer than 100 characters (the current length is [string length $certificate_from] characters).
	</li>"
} elseif { [string length $recipient_email] > 100 } {
    incr exception_count
    append exception_text "
	<li>
	  The recipient email address, $recipient_email you entered is too long.
	  It needs to contain fewer than 100 characters (the current length is [string length $recipient_email] characters).
	</li>"
}

if { $amount < [ad_parameter -package_id [ec_id] MinGiftCertificateAmount ecommerce] } {
    incr exception_count
    append exception_text "
	<li>
	  The amount, $amount needs to be at least [ec_pretty_price [ad_parameter -package_id [ec_id] MinGiftCertificateAmount ecommerce]]
	</li>"
} elseif { $amount > [ad_parameter -package_id [ec_id] MaxGiftCertificateAmount ecommerce] } {
    incr exception_count
    append exception_text "
	<li>
	   The amount, $amount cannot be higher than [ec_pretty_price [ad_parameter -package_id [ec_id] MaxGiftCertificateAmount ecommerce]]
	</li>"
}

if { [regexp {[^0-9]} $creditcard_number] } {

    # I've already removed spaces and dashes, so only numbers should remain

    incr exception_count
    append exception_text "
	<li>
	  Your credit card number contains invalid characters.
	</li>"
}

# Make sure the credit card type is right & that it has the right number
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

# User session tracking

set user_session_id [ec_get_user_session_id]
ec_log_user_as_user_id_for_this_session

# Doubleclick protection

if { [db_string get_gift_c_id "
    select count(*) 
    from ec_gift_certificates 
    where gift_certificate_id=:gift_certificate_id"] > 0 } {

    # Query the status of the gift certificate in the database

    set gift_certificate_state [db_string get_gift_c_status "
	select gift_certificate_state 
	from ec_gift_certificates 
	where gift_certificate_id=:gift_certificate_id"]

    switch -exact $gift_certificate_state {

	"authorized" {

	    # Present a thank you page

	    ad_returnredirect "gift-certificate-thank-you"
	    return
	}

	"failed_authorization" {

	    # Present a new gift_certificate_id and a new form
	    
	    set gift_certificate_id [db_nextval ec_gift_cert_id_sequence]
	    
	    set title "Credit Card Correction Needed"
	    set page "
		<blockquote>
		  <p>At this time we are unable to receive authorization to charge your
		  credit card. Please check the number and the expiration date and
		  try again or use a different credit card.</p>
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
		    </table>
		    <center>
		      <input type=submit value=\"Continue\">
		    </center>
		  </form>
		</blockquote>"
	}

	"confirmed" {
	    set n_seconds [db_string get_n_seconds "
		select round((sysdate-issue_date)*86400) as n_seconds 
		from ec_gift_certificates 
		where gift_certificate_id = :gift_certificate_id"]
    	    set title "Gift Certificate Order Already Processed"
	    set page "
    		<p>You've probably hit submit twice from the same form.  We are already
		in possession of a gift certificate order with id # $gift_certificate_id (placed $n_seconds
		seconds ago) and it is being processed.  You can <a href=\"gift-certificate?[export_url_vars gift_certificate_id]\">
		check on the status of this gift certificate order</a> if you like.</p>"
	}
	
	default {
	    db_dml report_gc_error_into_log "
		insert into ec_problems_log
		(problem_id, problem_date, problem_details, gift_certificate_id)
		values
		(ec_problem_id_sequence.nextval, sysdate, 
		    'Customer pushed reload on gift-certificate-finalize-order.tcl but gift_certificate_state wasn't authorized or failed.',:gift_certificate_id)"
	    set title "Unexpected Result"
	    set page "
		 <p>We received an unexpected result when querying for the status of your gift certificate. 
		 This problem has been logged. However, it would be helpful if you could email 
		 <a href=\"mailto:[ad_system_owner]\">[ad_system_owner]</a> with the events that led up to this occurrence.
		 We apologize for this problem and we will correct it as soon as we can.</p>"
	}
    }
} else {

    # Put in the credit card
    # Put in the gift certificate
    # Put in the transaction
    # Try to auth transaction
    
    db_transaction {
	
	set creditcard_id [db_nextval ec_creditcard_id_sequence]
	set ccstuff_1 "[string range $creditcard_number [expr [string length $creditcard_number] -4] [expr [string length $creditcard_number] -1]]"
	set expiry "$creditcard_expire_1/$creditcard_expire_2"
	db_dml get_ec_credit_card "
	    insert into ec_creditcards
    	    (creditcard_id, user_id, creditcard_number, creditcard_last_four, creditcard_type, creditcard_expire, billing_address)
    	    values
    	    (:creditcard_id, :user_id, :creditcard_number, :ccstuff_1, :creditcard_type, :expiry, :address_id)"
	
	# claim check is generated as follows:
	# 1. username of recipient (part of email address up to the @
	#    symbol) up to 10 characters
	# 2. 10 character random string
	# 3. gift_certificate_id
	# all separated by dashes
	
	# The username is added as protection in case someone cracks
	# the random number algorithm.  The gift_certificate_id is
	# added as a guarantee of uniqueness.

	# philg_email_valid_p ensures that there will be an @ sign,
	# thus a username will be set

	regexp {(.+)@} $recipient_email match username
	if { [string length $username] > 10 } {
	    set username [string range $username 0 9]
	}

	set random_string [ec_generate_random_string 10]
	set claim_check "$username-$random_string-$gift_certificate_id"
	set peeraddr [ns_conn peeraddr]
	set gc_months [ad_parameter -package_id [ec_id] GiftCertificateMonths ecommerce]
	db_dml insert_new_gc_into_db  "
	    insert into ec_gift_certificates
    	    (gift_certificate_id, gift_certificate_state, amount, issue_date, purchased_by, expires, claim_check, 
	     certificate_message, certificate_to, certificate_from, recipient_email, last_modified, last_modifying_user, modified_ip_address)
    	     values
    	    (:gift_certificate_id, 'confirmed', :amount, sysdate, :user_id, add_months(sysdate,:gc_months),:claim_check, 
	     :certificate_message, :certificate_to, :certificate_from, :recipient_email, sysdate, :user_id, :peeraddr)"
	
	set transaction_id [db_nextval ec_transaction_id_sequence]
	db_dml insert_ec_financial_trans "
	    insert into ec_financial_transactions
    	    (transaction_id, gift_certificate_id, creditcard_id, transaction_amount, transaction_type, inserted_date)
    	    values
    	    (:transaction_id, :gift_certificate_id, :creditcard_id, :amount, 'charge', sysdate)"
    }
    
    # try to authorize the transaction

    # Lookup the selected currency.

    set currency [ad_parameter Currency ecommerce]

    # Lookup the selected payment gateway

    set payment_gateway [ad_parameter PaymentGateway -default [ad_parameter -package_id [ec_id] PaymentGateway]]

    # Flag an error when no payment gateway has been selected or if
    # there is no binding between the selected gateway and the
    # PaymentGateway.

    if {[empty_string_p $payment_gateway] } {
	db_dml log_empty_gateway_error "
	    insert into ec_problems_log
	    (problem_id, problem_date, problem_details, gift_certificate_id)
	    values
	    (ec_problem_id_sequence.nextval, sysdate, 
	        'gift-certificate-finalize-order.tcl could not authorize a gift certificate as no payment gateway was selected.',:gift_certificate_id)"
	set title "Unexpected Result"
 	set page "
	     <p>We received an unexpected result when contacting the payment gateway for credit card authorization.
	     This problem has been logged. However, it would be helpful if you could email 
	     <a href=\"mailto:[ad_system_owner]\">[ad_system_owner]</a> with the events that led up to this occurrence.
	     We apologize for this problem and we will correct it as soon as we can.</p>"
    } else {
	if {![acs_sc_binding_exists_p "PaymentGateway" $payment_gateway]} {
	    db_dml log_unbound_gateway_error "
	    	insert into ec_problems_log
	    	(problem_id, problem_date, problem_details, gift_certificate_id)
	    	values
	    	(ec_problem_id_sequence.nextval, sysdate, 
	            'gift-certificate-finalize-order.tcl could not authorize a gift certificate as payment gateway $payment_gateway is not bound to the Payment Service Contract.',:gift_certificate_id)"
	    set title "Unexpected Result"
 	    set page "
		 <p>We received an unexpected result when contacting the payment gateway for credit card authorization.
	     	 This problem has been logged. However, it would be helpful if you could email 
	     	 <a href=\"mailto:[ad_system_owner]\">[ad_system_owner]</a> with the events that led up to this occurrence.
	     	 We apologize for this problem and we will correct it as soon as we can.</p>"
	} else {

	    # Lookup the credit card information for the
	    # transaction. There will be one since the card has just
	    # been inserted.

	    db_1row creditcard_data_select "
	    	select c.creditcard_number as card_number, substring(creditcard_expire for 2) as card_exp_month, substring(creditcard_expire from 4 for 2) as card_exp_year, c.creditcard_type,
		   p.first_names || ' ' || p.last_name as card_name, 
          	   a.zip_code as billing_zip,
	  	   a.line1 as billing_address, 
	  	   a.city as billing_city, 
          	   coalesce(a.usps_abbrev, a.full_state_name) as billing_state, 
          	   a.country_code as billing_country
	    	from ec_creditcards c, persons p, ec_addresses a
	    	where c.user_id=p.person_id 
	   	and c.creditcard_id = :creditcard_id
		and c.billing_address = a.address_id"

	    # Convert the one digit creditcard abbreviation to the
	    # standardized name of the card.

	    set card_type [ec_pretty_creditcard_type $creditcard_type]

	    # Connect to the payment gateway to authorize the transaction.

	    array set response [acs_sc_call "PaymentGateway" "Authorize" \
				    [list $transaction_id \
					 $amount \
					 $card_type \
					 $card_number \
					 $card_exp_month \
					 $card_exp_year \
					 $card_name \
					 $billing_address \
					 $billing_city \
					 $billing_state \
					 $billing_zip \
					 $billing_country] \
				    $payment_gateway]

	    # Extract response_code, reason and the gateway transaction id
	    # from the response. The response_code values are defined in
	    # payment-gateway/tcl/payment-gateway-init.tcl. The reason is a
	    # human readable description of the response and the
	    # transaction id is the ID as returned by the payment gateway.

	    set response_code $response(response_code)
	    set reason $response(reason)
	    set pgw_transaction_id $response(transaction_id)

	    # Interpret the response_code.

	    switch -exact $response_code {
		
		"failure" {
		    
		    # The payment gateway rejected to authorize the
		    # transaction. Or is not cable of authorizing
		    # transactions.
		    
		    # Probably don't need to do this update of
		    # to_be_captured_p because no cron jobs
		    # distinguish between null and 'f' right now, but
		    # it doesn't hurt and it might alleviate someone's
		    # concern when they're looking at
		    # ec_financial_transactions and wondering whether
		    # they should be concerned that failed_p is 't'

		    db_dml set_ft_failure "
			update ec_financial_transactions 
			set failed_p='t', to_be_captured_p='f' 
			where transaction_id=:transaction_id"
		    db_dml set_gc_failure "
			update ec_gift_certificates
			set gift_certificate_state='failed_authorization'
			where gift_certificate_id=:gift_certificate_id"

		    # Present a new gift_certificate_id and a new form

		    set gift_certificate_id [db_nextval ec_gift_cert_id_sequence]
		    
		    set title "Credit Card Correction Needed"
		    set page "
    			<blockquote>
    			  <p>At this time we are unable to receive authorization to charge your
    			  credit card. Please check the number and the expiration date and
    			  try again or use a different credit card.</p>
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
        		    </table>
        		    <center>
        		      <input type=submit value=\"Continue\">
        		    </center>
			  </form>
			</blockquote>"
		}
		
		"failure-retry" {

		    # If the response_code is failure-retry, it means
		    # there was a temporary failure that can be
		    # retried.  The transaction will be retried the
		    # next time the scheduled procedure
		    # ec_sweep_for_payment_zombies is run.

		    # Present a thank-you page.

		    ad_returnredirect "gift-certificate-thank-you"
		    return
		}

		"success" {

		    # The payment gateway authorized the transaction.

		    # Update transaction and gift certificate to
		    # authorized setting to_be_captured_p to 't' will
		    # cause ec_unmarked_transactions to come along and
		    # mark it for capture

		    db_dml update_ft_set_status "
			update ec_financial_transactions 
			set authorized_date=sysdate, to_be_captured_p='t', transaction_id = :pgw_transaction_id
			where transaction_id=:transaction_id"
		    db_dml update_ec_gc_status "
			update ec_gift_certificates 
			set authorized_date=sysdate, gift_certificate_state='authorized'
			where gift_certificate_id=:gift_certificate_id"
		    
		    # Send gift certificate order email

		    ec_email_new_gift_certificate_order $gift_certificate_id

		    # Present a thank-you page.

		    ad_returnredirect "gift-certificate-thank-you"
		    return
		}

		"not_supported" -
		"not_implemented" {

		    db_dml log_no_support_error "
			insert into ec_problems_log
			(problem_id, problem_date, problem_details, gift_certificate_id)
			values
			(ec_problem_id_sequence.nextval, sysdate, 
		    	    'Gift-certificate-finalize-order.tcl called payment gateway :payment_gateway for authorizion, which returned: :response_code.', :gift_certificate_id)"
		    set title "Unexpected Result"
		    set page "
			<p>We received an unexpected result when contacting the payment gateway for credit card authorization.
		 	This problem has been logged. However, it would be helpful if you could email 
		 	<a href=\"mailto:[ad_system_owner]\">[ad_system_owner]</a> with the events that led up to this occurrence.
		 	We apologize for this problem and we will correct it as soon as we can.</p>"
		}

		default {

		    # Unknown response_code

		    set title "Unknown response from payment gateway"
		    set page "
			<blockquote>
			  <p>We didn't receive confirmation from the payment gateway whether they were able to authorize the
			  payment for your gift certificate order.</p>

			  <p>We will contact the payment gateway to see if they processed your transaction, and
			  we'll let you know by email. We apologize for the inconvenience.</p>

			  <p>You can also <a href=\"gift-certificate?[export_url_vars gift_certificate_id]\">check on the status of
			  this gift certificate order</a>.</p>
			</blockquote>"
		}
	    }
	}
    }
}
