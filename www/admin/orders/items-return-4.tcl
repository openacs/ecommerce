ad_page_contract {

    This script does the following:
    1. tries to get credit card number (insert it if new)
    2. puts records into ec_refunds, individual items, the order, and
       ec_financial transactions
    3. does the gift certificate reinstatements
    4. tries to do refund

    @param refund_id
    @param order_id
    @param received_back_datetime
    @param reason_for_return
    @param item_id_list
    @param price_to_refund
    @param shipping_to_refund
    @param base_shipping_to_refund
    @param cash_amount_to_refund
    @param certificate_amount_to_reinstate
    
    @param creditcard_id
    @param creditcard_type
    @param creditcard_number

    @author Eve Andersson (eveander@arsdigita.com)
    @creation-date  July 22, 1999
    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} { 
    refund_id:naturalnum,notnull
    order_id:naturalnum,notnull
    received_back_datetime
    reason_for_return
    item_id_list:notnull
    price_to_refund:array
    shipping_to_refund:array
    base_shipping_to_refund
    cash_amount_to_refund:optional
    certificate_amount_to_reinstate

    creditcard_id:optional
    creditcard_type:optional
    creditcard_number:optional
    creditcard_last_four:optional
}

# The customer service rep must be logged on and have admin
# privileges.

ad_require_permission [ad_conn package_id] admin
set customer_service_rep [ad_get_user_id]

# Get rid of spaces and dashes

regsub -all -- "-" $creditcard_number "" creditcard_number
regsub -all -- " " $creditcard_number "" creditcard_number

# Error checking: unless the credit card number is in the database or
# if the total amount to refund is $0.00 the credit card number needs
# to be re-entered.

set exception_count 0
set exception_text ""

# Make sure that this refund hasn't been processed before. (Double
# click prevention.)

if { [db_string get_refund_id_check "
    select count(*) 
    from ec_refunds 
    where refund_id=:refund_id"] > 0 } {
    ad_return_complaint 1 "
	<li>This refund has already been inserted into the database. Are you using an old form? <a href=\"one?[export_url_vars order_id]\">Return to the order.</a></li>"
    return
}

# Check if money needs to be refunded and if the credit card number is
# still on file.

if { [expr $cash_amount_to_refund] > 0 } {

    # Make sure that all the credit card information is there.

    if {![info exists creditcard_id] || ([info exists creditcard_id] && [empty_string_p $creditcard_id])} {
	incr exception_count
	append exception_text "
	    <li>
	      You forgot to provide the creditcard that was used to purchase the items to be returned.
	    </li>"
    }
    if {![info exists creditcard_type] || ([info exists creditcard_type] && [empty_string_p $creditcard_type])} {
	incr exception_count
	append exception_text "
	    <li>
	      You forgot to provide type of the creditcard that was used to purchase the items to be returned.
	    </li>"
    }
    if {![info exists creditcard_number] || ([info exists creditcard_number] && [empty_string_p $creditcard_number])} {
	incr exception_count
	append exception_text "
	    <li>
	      You forgot to provide card number of the creditcard that was used to purchase the items to be returned.
	    </li>"
    }
    if {![info exists creditcard_last_four] || ([info exists creditcard_last_four] && [empty_string_p $creditcard_last_four])} {
	incr exception_count
	append exception_text "
	    <li>
	      You forgot to provide card number of the creditcard that was used to purchase the items to be returned.
	    </li>"
    }
    
    # The credit card has been re-entered. Check that the number is
    # correct.
    
    if { [regexp {[^0-9]} $creditcard_number] } {
	incr exception_count
	append exception_text "<li>The credit card number contains invalid characters.</li>"
    }
    
    if {[string length $creditcard_number] > 4 && ![string match *$creditcard_last_four $creditcard_number]} {
	incr exception_count
	append exception_text "<li>The last for digits of the credit card number do not match the digits on file.<br>
	    Make sure to enter the card number of the credit card that was used to pay for the order.</li>"
    }

    if {[info exists creditcard_type]} {

	# Make sure the credit card number matches the credit card
	# type # and that the number has the right number of digits.

	set additional_count_and_text [ec_creditcard_precheck $creditcard_number $creditcard_type]
    
	set exception_count [expr $exception_count + [lindex $additional_count_and_text 0]]
	append exception_text [lindex $additional_count_and_text 1]
    }
}

if { $exception_count > 0 } {
    ad_return_complaint $exception_count $exception_text
    return
}

# Done with error checking

# 2. Put records into ec_refunds, individual items, the order, and
#    ec_financial_transactions

db_dml update_cc_number_incctable "
    update ec_creditcards 
    set creditcard_number=:creditcard_number 
    where creditcard_id=:creditcard_id"
db_dml insert_new_ec_refund "
    insert into ec_refunds
    (refund_id, order_id, refund_amount, refund_date, refunded_by, refund_reasons)
    values
    (:refund_id, :order_id, :cash_amount_to_refund, sysdate, :customer_service_rep,:reason_for_return)"

foreach item_id $item_id_list {

    # This is annoying (doing these selects before each insert),
    # but that's how it goes because we don't want to refund more
    # tax than was actually paid even if the tax rates changed
    
    set price_bind_variable $price_to_refund($item_id)
    set shipping_bind_variable $shipping_to_refund($item_id)

    db_1row get_tax_charged_on_item "
	select nvl(price_tax_charged,0) as price_tax_charged, nvl(shipping_tax_charged,0) as shipping_tax_charged 
	from ec_items 
	where item_id=:item_id"

# torben diagnostics note: following calls for ec_tax, but ec_tax does not exist.    
    set price_tax_to_refund [ec_min $price_tax_charged [db_string get_tax_charged "
	select ec_tax(:price_bind_variable,0,:order_id) 
	from dual"]]
    
    set shipping_tax_to_refund [ec_min $shipping_tax_charged [db_string get_tax_shipping_to_refund "
	select ec_tax(0,:shipping_bind_variable,:order_id) 
	from dual"]]
    
    db_dml update_item_return "
	update ec_items 
	set item_state='received_back', received_back_date=to_date(:received_back_datetime,'YYYY-MM-DD HH12:MI:SSAM'), price_refunded=:price_bind_variable,
	shipping_refunded=:shipping_bind_variable, price_tax_refunded=:price_tax_to_refund, shipping_tax_refunded=:shipping_tax_to_refund, refund_id=:refund_id
	where item_id=:item_id"
}

set base_shipping_tax_charged [db_string get_base_shipping_tax "
    select nvl(shipping_tax_charged,0) 
    from ec_orders 
    where order_id=:order_id"]
set base_shipping_tax_to_refund [ec_min $base_shipping_tax_charged [db_string get_base_tax_to_refund "
    select ec_tax(0,:base_shipping_to_refund,:order_id) 
    from dual"]]
db_dml update_ec_order_set_shipping_refunds "
    update ec_orders 
    set shipping_refunded=:base_shipping_to_refund, shipping_tax_refunded=:base_shipping_tax_to_refund 
    where order_id=:order_id"

# Match the refund up with prior charge transactions. Some payment
# gateways such Authorize.net require that each refund is linked
# to a prior charge transaction and that the refund amount does
# not exceed the amount of the charge transaction. The refund
# amount can exceed the charge amount when the order was shipped
# in parts and the customer returned items from various shipments.

set refund_amount $cash_amount_to_refund 
while { $refund_amount > 0 } {
    
    # See if the refund matches a single charge transaction. The
    # test < 0.01 is needed for reasons of rounding errors.
    
    if {[db_0or1row select_matching_charge_transaction "
	select transaction_id as charged_transaction_id, marked_date 
	from ec_financial_transactions 
	where order_id = :order_id
	and transaction_type = 'charge' 
	and (transaction_amount - :refund_amount) < 0.01::numeric 
	and (transaction_amount - :refund_amount) > 0::numeric 
	and refunded_amount is null
	and marked_date is not null
	and failed_p = 'f'
	order by transaction_id
	limit 1"]} {

	# Create a single refund financial transaction.

	set refund_transaction_id [db_nextval ec_transaction_id_sequence]

	# Authorize.net is an example of a payment gateway that requires
	# the original transaction to be settled before it accepts refunds
	# for the transaction. Unfortunately there is no automated way to
	# find out if the transaction has been settled.

	# However, transactions are settled once a day (by all gateways)
	# thus it is safe to assume that transactions are settled within
	# 24 hours after they have been marked for settlement.

	set 24hr [expr 24 * 60 * 60]
	set time_since_marking [expr [clock seconds] - [clock scan $marked_date]]
	if { $time_since_marking > $24hr } {
	    set scheduled_hour [clock format [clock scan $marked_date] -format "%Y-%m-%d %H:%M:%S" -gmt true]
	} else {

	    # It is too early to perform the refund now. First the
	    # original transaction needs to be settled by the payment
	    # gateway. Schedule the refund for 24 hours after the original
	    # transaction was marked for settlement. The procedure
	    # ec_unrefunded_transactions will then perform the shortly
	    # after the scheduled hour.

	    set scheduled_hour [clock format [expr [clock scan $marked_date] + $24hr] -format "%Y-%m-%d %H:%M:%S" -gmt true]
	}
# torben diagnostics note: following insert does not make it into ec_financial_transactions.
	db_dml insert_refund_transaction "
	    insert into ec_financial_transactions
	    (transaction_id, refunded_transaction_id, order_id, refund_id, creditcard_id, transaction_amount, transaction_type, inserted_date, to_be_captured_date)
	    values
	    (:refund_transaction_id, :charged_transaction_id, :order_id, :refund_id, :creditcard_id, :refund_amount, 'refund', sysdate, :scheduled_hour)"

	# Record the amount that was refunded of the charge transaction.

	db_dml record_refunded_amount "
	    update ec_financial_transactions
	    set refunded_amount = coalesce(refunded_amount, 0) + :refund_amount
	    where transaction_id = :charged_transaction_id"

	# Set the amount to be refunded to zero to indicate that
	# no more refunds are needed.

	set refund_amount 0
    } elseif {[db_0or1row select_unrefunded_charge_transaction "
	select transaction_id as charged_transaction_id, (transaction_amount - coalesce(refunded_amount, 0)) as unrefunded_amount, marked_date
	from ec_financial_transactions
	where order_id = :order_id
	and transaction_type = 'charge' 
	and (transaction_amount - coalesce(refunded_amount, 0)) > 0.01::numeric
	and marked_date is not null
	and failed_p = 'f'
	order by (transaction_amount - coalesce(refunded_amount, 0)) desc
	limit 1"]} {
	
	if { $unrefunded_amount >= $refund_amount } {

	    # Create refund financial transaction for the refund
	    # amount.

	    set refund_transaction_id [db_nextval ec_transaction_id_sequence]

	    # Authorize.net is an example of a payment gateway that requires
	    # the original transaction to be settled before it accepts refunds
	    # for the transaction. Unfortunately there is no automated way to
	    # find out if the transaction has been settled.

	    # However, transactions are settled once a day (by all gateways)
	    # thus it is safe to assume that transactions are settled within
	    # 24 hours after they have been marked for settlement.

	    set 24hr [expr 24 * 60 * 60]
	    set time_since_marking [expr [clock seconds] - [clock scan $marked_date]]
	    if { $time_since_marking > $24hr } {
		set scheduled_hour [clock format [clock scan $marked_date] -format "%Y-%m-%d %H:%M:%S" -gmt true]
	    } else {

		# It is too early to perform the refund now. First the
		# original transaction needs to be settled by the payment
		# gateway. Schedule the refund for 24 hours after the original
		# transaction was marked for settlement. The procedure
		# ec_unrefunded_transactions will then perform the shortly
		# after the scheduled hour.

		set scheduled_hour [clock format [expr [clock scan $marked_date] + $24hr] -format "%Y-%m-%d %H:%M:%S" -gmt true]
	    }

	    db_dml insert_refund_transaction "
		insert into ec_financial_transactions
		(transaction_id, refunded_transaction_id, order_id, refund_id, creditcard_id, transaction_amount, transaction_type, inserted_date, to_be_captured_date)
		values
		(:refund_transaction_id, :charged_transaction_id, :order_id, :refund_id, :creditcard_id, :refund_amount, 'refund', current_timestamp, :scheduled_hour)"

	    # Record the amount that was refunded of the charge transaction.

	    db_dml record_refunded_amount "
		update ec_financial_transactions
		set refunded_amount = coalesce(refunded_amount, 0) + :refund_amount
		where transaction_id = :charged_transaction_id"

	    # Set the amount to be refunded to zero to indicate that
	    # no more refunds are needed.

	    set refund_amount 0
	} else {

	    # Create refund financial transaction for the unrefunded
	    # amount of the charge transaction.

	    set refund_transaction_id [db_nextval ec_transaction_id_sequence]

	    # Authorize.net is an example of a payment gateway that requires
	    # the original transaction to be settled before it accepts refunds
	    # for the transaction. Unfortunately there is no automated way to
	    # find out if the transaction has been settled.

	    # However, transactions are settled once a day (by all gateways)
	    # thus it is safe to assume that transactions are settled within
	    # 24 hours after they have been marked for settlement.

	    set 24hr [expr 24 * 60 * 60]
	    set time_since_marking [expr [clock seconds] - [clock scan $marked_date]]
	    if { $time_since_marking > $24hr } {
		set scheduled_hour [clock format [clock scan $marked_date] -format "%Y-%m-%d %H:%M:%S" -gmt true]
	    } else {

		# It is too early to perform the refund now. First the
		# original transaction needs to be settled by the payment
		# gateway. Schedule the refund for 24 hours after the original
		# transaction was marked for settlement. The procedure
		# ec_unrefunded_transactions will then perform the shortly
		# after the scheduled hour.

		set scheduled_hour [clock format [expr [clock scan $marked_date] + $24hr] -format "%Y-%m-%d %H:%M:%S" -gmt true]
	    }

	    db_dml insert_unrefund_transaction "
		insert into ec_financial_transactions
		(transaction_id, refunded_transaction_id, order_id, refund_id, creditcard_id, transaction_amount, transaction_type, inserted_date, to_be_captured_date)
		values
		(:refund_transaction_id, :charged_transaction_id, :order_id, :refund_id, :creditcard_id, :unrefunded_amount, 'refund', sysdate, :scheduled_hour)"

	    # Record the amount that was refunded of the charge transaction.

	    db_dml record_unrefunded_amount "
		update ec_financial_transactions
		set refunded_amount = coalesce(refunded_amount, 0) + :unrefunded_amount
		where transaction_id = :charged_transaction_id"

	    # Subtract the amount of the new refund transaction
	    # from the total amount to be refunded.

	    set refund_amount [expr $refund_amount - $unrefunded_amount]
	}
    }
}

# 3. do the gift certificate reinstatements (start with ones that
# expire furthest in to future)

if { $certificate_amount_to_reinstate > 0 } {
    
    set certificate_amount_used [db_string get_gc_amount_used "
	select ec_order_gift_cert_amount(:order_id) 
	from dual"]

    if { $certificate_amount_used < $certificate_amount_to_reinstate } {
	set errorstring "
	    We were unable to reinstate the customer's gift certificate balance because the amount to be reinstated was 
	    larger than the original amount used. This shouldn't have happened unless there was a programming error or unless the
	    database was incorrectly updated manually. This transaction was aborted (refund_id $refund_id), i.e. no refund was
	    given to the customer."
	db_dml record_reinstate_problem "
	    insert into ec_problems_log
	    (problem_id, problem_date, problem_details, order_id)
	    values
	    (ec_problem_id_sequence.nextval, sysdate, :errorstring, :order_id)"
	ad_return_error "
	    <p>Gift Certificate Error" "We were unable to reinstate the customer's gift certificate balance because the amount
	      to be reinstated was larger than the original amount used.  This shouldn't have happened unless there was a programming error
	      or unless the database was incorrectly updated manually.</p>
	    <p>This transaction has been aborted, i.e. no refund has been given to the customer. This has been logged in the problems log.</p>"
	return
    }

    # Go through and reinstate certificates in order; it's not so bad
    # to loop through all of them because there won't be many.

    db_foreach reinstateable_gift_certificates "
	select u.gift_certificate_id, coalesce(sum(u.amount_used),0) - coalesce(sum(u.amount_reinstated),0) as reinstateable_amount
	from ec_gift_certificate_usage u, ec_gift_certificates c
	where u.gift_certificate_id = c.gift_certificate_id
	and u.order_id = :order_id
	group by u.gift_certificate_id, c.expires
	order by expires desc, gift_certificate_id desc" {

	if {$certificate_amount_to_reinstate > 0} {
	    db_dml reinstate_gift_certificate "
		insert into ec_gift_certificate_usage
		(gift_certificate_id, order_id, amount_reinstated, reinstated_date)
		values
		(:gift_certificate_id, :order_id, least(to_number(:certificate_amount_to_reinstate), to_number(:reinstateable_amount)) , sysdate)"
	    set $certificate_amount_to_reinstate [expr $certificate_amount_to_reinstate - \
						      [expr ($certificate_amount_to_reinstate > $reinstateable_amount) ? $reinstateable_amount : $certificate_amount_to_reinstate]]
	}
    }
}

# 4. Try to do the refund(s)

if {$cash_amount_to_refund > 0} {
    set page_title "Refund results"
    set results_explanation ""
    db_foreach select_unrefund_transactions "
	select transaction_id, transaction_amount, refunded_transaction_id, to_be_captured_date
	from ec_financial_transactions
	where order_id = :order_id
	and transaction_type = 'refund'
	and refunded_date is null
	and failed_p = 'f'" {

        set now [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S" -gmt true]
	if { [dt_interval_check $to_be_captured_date $now] > 0} {

	    array set response [ec_creditcard_return $transaction_id]
	    set refund_status $response(response_code)
	    set pgw_transaction_id $response(transaction_id)
	    if { $refund_status == "failure" || $refund_status == "invalid_input" } {
		set errorstring "Refund transaction $transaction_id  for [ec_pretty_price $transaction_amount] of refund $refund_id at [ad_conn url], resulted in: $refund_status"
		db_dml insert_cc_refund_problem "
		    insert into ec_problems_log
		    (problem_id, problem_date, problem_details, order_id)
		    values
		    (ec_problem_id_sequence.nextval, sysdate, :errorstring, :order_id)"
		append results_explanation "<p>Refund transaction $transaction_id  for [ec_pretty_price $transaction_amount] did not occur.
		    We have made a record of this in the problems log so that the situation can be corrected manually.</p>"
	    } elseif { $refund_status == "inconclusive" } {

		# Set the to_be_captured_date so that the scheduled
		# procedure ec_unrefunded_transactions will retry the
		# transaction.

		append results_explanation "<p>The results of refund transaction $transaction_id for [ec_pretty_price $transaction_amount] were inconclusive 
		    (perhaps due to a communications failure between us and the payment gateway).
		    A program will keep trying to complete this refund transaction and the problems log will be updated if it the refund transaction cannot be completed.</p>"
	    } else {

		# Refund successful

		db_dml update_ft_set_success "
		    update ec_financial_transactions 
		    set refunded_date=sysdate 
		    where transaction_id=:pgw_transaction_id"
		append results_explanation "<p>Refund transaction $pgw_transaction_id for [ec_pretty_price $transaction_amount] is complete!</p>";# 
	    }
	} else {

	    # It is too early to perform the refund now. First the
	    # original transaction needs to be settled by the payment
	    # gateway. 

	    append results_explanation "<p>Refund transaction $transaction_id  for [ec_pretty_price $transaction_amount] is scheduled for a later time. 
		Refunds can not be processed before the transaction charging the credit card has been completed by the gateway. 
		Transactions are completed with 24 hours after marking. Therefore the refund transaction has been scheduled for $to_be_captured_date</p>"

	}
    } if_no_rows {
	set page_title "No credit card refund needed."
	set results_explanation "No credit card refund was necessary because the entire amount was refunded to the gift certificates the customer used when purchasing the order."
    }
} else {
	set page_title "No credit card refund needed."
	set results_explanation "No credit card refund was necessary because the entire amount was refunded to the gift certificates the customer used when purchasing the order."
}

append doc_body "
    [ad_admin_header $page_title]

    <h2>$page_title</h2>

    [ad_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index" "Orders"] [list "one?[export_url_vars order_id]" "One"] "Refund Complete"]
    <hr>
    <blockquote>
      $results_explanation
      <a href=\"one?[export_url_vars order_id]\">Back to Order $order_id</a>
    </blockquote>
    [ad_admin_footer]"

doc_return  200 text/html $doc_body
