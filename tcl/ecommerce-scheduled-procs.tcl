# /tcl/ecommerce-scheduled-procs.tcl
ad_library {

  Scheduled procedures for the ecommerce module.
  Other ecommerce procedures can be found in ecommerce-*.tcl

  Procedures:

    ec_calculate_product_purchase_combinations
    ec_sweep_for_payment_zombies
    ec_sweep_for_payment_zombie_gift_certificates
    ec_send_unsent_new_order_email
    ec_send_unsent_new_gift_certificate_order_email
    ec_send_unsent_gift_certificate_recipient_email
    ec_delayed_credit_denied
    ec_expire_old_carts
    ec_remove_creditcard_data

  Financial transaction procedures:

    ec_unauthorized_transactions     - to_be_captured_date is over 1/2 hr old 
                                       and authorized_date is null

    ec_unmarked_transactions         - to_be_captured_p is 't' 
                                       and authorized_date is not null 
                                       and marked_date is null

    ec_unrefunded_transactions       - transaction_type is 'refund' 
                                       and inserted_date is over 1/2 hr old 
                                       and refunded_date is null

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date April 1999
  @author ported by Jerry Asher (jerry@theashergroup.com)
  @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
  @revision-date March 2002

}

ad_proc ec_calculate_product_purchase_combinations {
} { 

    Find product purchase combinations and store those in
    ec_product_purchase_comb.

    This procedure runs nightly so that calculations of popular product
    combinations don't have to be done each time a product's page is
    accessed. The procedure looks at all orders, not just orders which
    have been confirmed, so that there will be more data. *Technically*
    the calculation isn't a calculation of people who bought this
    product also bought these products, because the buying didn't have
    to take place. Placing products into the cart is sufficient to be
    included in the calculation.

} {

    # First prune expired combinations. A combination is deemed
    # expired when one of the products is inactive.

    ec_prune_product_purchase_combinations

    # For each active product find other active products that are
    # items of orders with the same user_id.

    db_foreach products_select "select product_id from ec_products where active_p = 't'" {

	# Then find current product combinations.

	set correlated_product_counter 0
	set insert_cols [list]
	set insert_vals [list]
	set update_items [list]
  
	db_foreach correlated_products_select "
	    select i2.product_id as correlated_product_id, count(*) as n_product_occurrences
	    from ec_items i2, ec_products p
	    where i2.order_id in (select o2.order_id
		from ec_orders o2
		where o2.user_id in (select user_id
		     from ec_orders o
		     where o.order_id in (select i.order_id
			  from ec_items i
			  where product_id = :product_id)))
	     and i2.product_id <> :product_id
	     and i2.product_id = p.product_id
	     and p.active_p = 't'
	     group by i2.product_id
	     order by n_product_occurrences desc" {
	    if { $correlated_product_counter >= 5 } {
		break
	    }
	    
	    # Unknown at this point whether it will be an update or
	    # insert.

	    lappend insert_cols "product_$correlated_product_counter"
	    lappend insert_vals $correlated_product_id
	    lappend update_items "product_$correlated_product_counter = $correlated_product_id"
	    incr correlated_product_counter
	}

	if { [db_string product_purchase_comb_select "
		select count(*) 
		from ec_product_purchase_comb 
		where product_id=:product_id"] == 0 } {
	    if { [llength $insert_cols] > 0 } {

		# Insert the new product purchase combination.

		db_dml product_purchase_comb_insert "
		    insert into ec_product_purchase_comb
		    (product_id, [join $insert_cols ", "])
		    values
		    (:product_id, [join $insert_vals ", "])"

	    }
	} else {
	    if { [llength $update_items] > 0 } {

		# Update an existing product purchase combination.

		db_dml product_purchase_comb_update "
		    update ec_product_purchase_comb
		    set [join $update_items ", "]
		    where product_id=:product_id"

	    }
	}
    }
}

ad_proc ec_sweep_for_payment_zombies {
} {

    Cron job to dig up confirmed orders over 15 minutes old ("zombies") 
    that did not fail and haven't been authorized . 

    These only happen when there is no response from the payment
    gateway when authorizing an order or the response indicated 
    nothing about whether the card was actually valid.  

    It also happens if the consumer pushes reload after the order
    is inserted into the database but before it goes through to 
    the payment gateway. 

    OVERALL STRATEGY

    (1) If the authorization was successful, update order_state to 
    authorized
    
    (2) If the response was inconclusive, leave the order in this state.

    (3) If the retry failed definitely, change order_state to
    failed_authorization (it will later be moved back to in_basket
    by ec_delayed_credit_denied)

} {

    # Lookup the selected currency.

    set currency [ad_parameter Currency ecommerce]

    # Lookup the selected payment gateway

    set payment_gateway [ad_parameter PaymentGateway -default [ad_parameter -package_id [ec_id] PaymentGateway]]
    if {[empty_string_p $payment_gateway] } {
	    ns_log warning "ec_sweep_for_payment_zombies: No payment gateway has been selected."
	    return
    } else {
	if {![acs_sc_binding_exists_p "PaymentGateway" $payment_gateway]} {
	    ns_log warning "ec_sweep_for_payment_zombies: Payment gateway $payment_gateway is not bound to the Payment Service Contract."
	    return
	}
    }

    # Select the transaction of all orders that have been confirmed
    # over 15 minutes ago. These orders should have reached either an
    # authorized state or failure state if the credit card
    # authorization failed. Orders that are still in the confirmed
    # state need to be reprocessed. At this stage there is a one on
    # one relationship between transactions and orders.

    db_foreach transactions_select "
	select o.order_id, ec_order_cost(o.order_id) as total_order_price, 
	    f.transaction_id, f.inserted_date, f.transaction_amount, c.creditcard_type as card_type, 
	    p.first_names || ' ' || p.last_name as card_name, 
	    c.creditcard_number as card_number, substring(creditcard_expire for 2) as card_exp_month, substring(creditcard_expire from 4 for 2) as card_exp_year, c.creditcard_type,
	    a.zip_code as billing_zip,
            a.line1 as billing_address, 
            a.city as billing_city, 
            coalesce(a.usps_abbrev, a.full_state_name) as billing_state, 
            a.country_code as billing_country
	from ec_orders o, ec_financial_transactions f, ec_creditcards c, persons p 
	where order_state = 'confirmed' 
	and (sysdate - confirmed_date) > 1/96
	and f.failed_p = 'f'
	and f.order_id = o.order_id
	and f.creditcard_id = c.creditcard_id 
	and c.user_id = p.person_id
	and c.billing_address = a.address_id" {

        # Log the orders that are being processed.

	ns_log notice "ec_sweep_for_payment_zombies working on transaction $transaction_id"
	    
	# If the order amount is 0 (zero) then there is thus no need
	# to contact the payment gateway. Record an instant success.

	if { $total_order_price == 0 } {

	    # Update the status of the order to authorized
	    
	    ec_update_state_to_authorized $order_id

	} else {

	    # Convert the one digit creditcard abbreviation to the
	    # standardized name of the card.

	    set card_type [ec_pretty_creditcard_type $creditcard_type]

	    # Connect to the payment gateway to authorize the transaction.

	    array set response [acs_sc_call "PaymentGateway" "Authorize" \
				    [list $transaction_id \
					 $transaction_amount \
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

		"failure" -
		"not_supported" -
		"not_implemented" -
		default {

		    # The payment gateway rejected to authorize the
		    # transaction, can not authorize any transaction
		    # or the gateway returned an unknown
		    # response_code. Fail the authorization to be on
		    # the safe side.
		    
		    # Set the order status to
		    # failed_authorization. Later the proc
		    # ec_delayed_credit_denied will change the status
		    # to in_basket.

		    db_dml order_failure_update "
			update ec_orders 
			set order_state = 'failed_authorization' 
			where order_id = :order_id"

		    db_dml transaction_failure_update "
			update ec_financial_transactions
			set failed_p = 't'
			where transaction_id = :transaction_id"
		}
		
		"failure-retry" {
		    
		    # The response_code is failure-retry, this means
		    # there was a temporary failure that can be
		    # retried. Fail the transaction however, if the
		    # order was confirmed a while ago (as defined in
		    # package parameter PaymentRetryPeriod) the
		    # temporary failure turns out to be less
		    # 'temporary'.

		    if { [expr [dt_interval_check $inserted_date [clock format [clock seconds] -format "%D %H:%M:%S"]] / (60 * 60) ] > \
			     [ad_parameter PaymentRetryPeriod -default [ad_parameter -package_id [ec_id] PaymentRetryPeriod]] } {

			db_transaction {

			    # Flag the transaction as failed so that it
			    # will not be retried. Don't set the order to
			    # 'failed_authorization' as this is a
			    # technical problem with the payment gateway
			    # that the customer has nothing to do with.

			    db_dml transaction_failure_update "
  			    	update ec_financial_transactions
			    	set failed_p = 't'
			    	where transaction_id = :transaction_id"

			    # Log this failure in the problem log.

			    set problem_details "Transaction $transaction_id failed to authorize due to repeated 'failure-retry' reponses from the payment gateway"
			    db_dml problems_log_insert "
			    	insert into ec_problems_log
			    	(problem_id, problem_date, problem_details, order_id)
			    	values
			    	(ec_problem_id_sequence.nextval, sysdate, :problem_details, :order_id)"
			}
			
		    } else {
			
			# Leave the order as is so that the order will
			# be retried the next time this procedure is
			# run.
			
		    }
		} 

		"success" {
		    
		    # The payment gateway authorized the transaction.
		    # Update the status of the order to
		    # authorized. And update the transaction_id to the
		    # id returned by the payment gateway.

		    ec_update_state_to_authorized $order_id
		    db_dml update_transaction_id "
			update ec_financial_transactions 
			set transaction_id = :pgw_transaction_id
			where transaction_id = :transaction_id"
		    
		}
	    }
	}
    }
}

ad_proc ec_sweep_for_payment_zombie_gift_certificates {
} {

    Looks for confirmed gift certificates that aren't either failed
    or authorized, i.e., where we didn't hear back from the payment
    cron job to dig up confirmed but not failed or authorized gift
    certificates over 15 minutes old ("zombies"). 

    These only happen when authorizing a transaction returned
    failure-retry, : an inconclusive failure. In other words the
    response indicated nothing about whether the card was actually
    valid. 

    It can also happen if the consumer pushes reload after the gift
    certificate is inserted into the database but before it goes
    through to the payment gateway.

    This proc is similar to ec_sweep_for_payment_zombies except that
    inconclusiveness is not tolerated in the case of gift
    certificates.  If the response from the payment gateway is
    inconclusive fail the transaction and send a note to the user to
    reorder.

} {
    
    # Lookup the selected currency.

    set currency [ad_parameter Currency ecommerce]

    # Lookup the selected payment gateway

    set payment_gateway [ad_parameter PaymentGateway -default [ad_parameter -package_id [ec_id] PaymentGateway]]
    if {[empty_string_p $payment_gateway] } {
	    ns_log warning "ec_sweep_for_payment_zombie_gift_certificates: No payment gateway has been selected."
	    return
    } else {
	if {![acs_sc_binding_exists_p "PaymentGateway" $payment_gateway]} {
	    ns_log warning "ec_sweep_for_payment_zombie_gift_certificates: Payment gateway $payment_gateway is not bound to the Payment Service Contract."
	    return
	}
    }

    # Select all gift certificates that have been confirmed over 15
    # minutes ago. These certificates should have reached either an
    # authorized state or failure state if the credit card
    # authorization failed. Certificates that are still in the
    # confirmed state need to be reprocessed. There's a one on one
    # correspondence between user-purchased gift certificates and
    # transactions.

    db_foreach transactions_select "
	select g.gift_certificate_id, f.transaction_id, f.transaction_amount, f.inserted_date, 
	    c.creditcard_type, c.creditcard_number as card_number, substring(creditcard_expire for 2) as card_exp_month, substring(creditcard_expire from 4 for 2) as card_exp_year, 
	    p.first_names || ' ' || p.last_name as card_name, 
            a.zip_code as billing_zip,
            a.line1 as billing_address, 
	    a.city as billing_city, 
            coalesce(a.usps_abbrev, a.full_state_name) as billing_state, 
            a.country_code as billing_country
	from ec_gift_certificates g, ec_financial_transactions f, ec_creditcards c, persons p 
	where g.gift_certificate_state = 'confirmed' 
	and (sysdate - g.issue_date) > 1/96
	and g.gift_certificate_id = f.gift_certificate_id
	and f.creditcard_id = c.creditcard_id 
	and c.user_id = p.person_id
        and c.billing_address = a.address_id" {
	    
        ns_log notice "ec_sweep_for_payment_zombies_gift_certificates working on transaction $transaction_id"
	    
	# Convert the one digit creditcard abbreviation to the
	# standardized name of the card.

	set card_type [ec_pretty_creditcard_type $creditcard_type]

	# Connect to the payment gateway to authorize the transaction.

	array set response [acs_sc_call "PaymentGateway" "Authorize" \
				[list $transaction_id \
				     $transaction_amount \
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
	# human readable description of the response and the transaction
	# id is the ID as returned by the payment gateway.

	set response_code $response(response_code)
	set reason $response(reason)
	set pgw_transaction_id $response(transaction_id)

	# Interpret the response_code.

	switch -exact $response_code {
	    
	    "failure" -
	    "failure-retry" -
	    "not_supported" -
	    "not_implemented" -
	    default {

		# The payment gateway rejected to authorize the
		# transaction, can not authorize any transaction or the
		# gateway returned an unknown response_code. Fail the
		# authorization to be on the safe side. Update gift
		# certificate and transaction to failed, and send a gift
		# certificate order failure email to the user.
		
		# There is no immediate need to update of
		# to_be_captured_p because no cron jobs distinguish
		# between null and 'f' right now, but it doesn't hurt
		# and it might alleviate someone's concern when they're
		# looking at ec_financial_transactions and wondering
		# whether they should be concerned that failed_p is 't'

		db_dml transaction_failure_update "
                  update ec_financial_transactions 
                  set failed_p = 't', to_be_captured_p = 'f' 
                  where transaction_id=:transaction_id"

		db_dml certificate_failure_update "
                  update ec_gift_certificates 
                  set gift_certificate_state='failed_authorization' 
                  where gift_certificate_id=:gift_certificate_id"

		# Send a gift certificate order failure email to the user.

		ec_email_gift_certificate_order_failure $gift_certificate_id
	    }
	    
	    "success" {

		# The payment gateway authorized the transaction. Update
		# the transaction and gift certificate to authorized,
		# and send a gift certificate order email to the user.

		# Update transaction and gift certificate to authorized
		# setting to_be_captured_p to 't' will cause
		# ec_unmarked_transactions to come along and mark it for
		# capture

		db_dml transaction_success_update "
		  update ec_financial_transactions
		  set transaction_id = :pgw_transaction_id, authorized_date=sysdate,
		  to_be_captured_p='t'
		  where transaction_id = :transaction_id"

		db_dml certificate_success_update "
		  update ec_gift_certificates
		  set authorized_date = sysdate,
		  gift_certificate_state = 'authorized'
		  where gift_certificate_id = :gift_certificate_id"
		
		# Send out the gift certificate order email

		ec_email_new_gift_certificate_order $gift_certificate_id
	    }
	}
    }
}

ad_proc ec_send_unsent_new_order_email {
} {

    Finds authorized orders for which confirmation email has not
    been sent, sends the email, and records that it has been sent.

    This procedure is needed because new order email is only sent
    after the order is authorized and some authorizations occur when
    the user is not on the web site or execution of the thread on
    the site may terminate after the order is authorized but before
    the email is sent

} {
    db_foreach orders_select "
	select order_id
	from ec_orders o
	where order_state='authorized'
	and (0=(select count(*) 
            from ec_automatic_email_log log 
            where log.order_id=o.order_id and email_template_id=1))" {
	ec_email_new_order $order_id
    }
}

ad_proc ec_send_unsent_new_gift_certificate_order_email {
} {

    Finds authorized gift certificates for which confirmation email
    has not been sent, sends the email, and records that it has been
    sent.

} {

    db_foreach certificates_select "
	select gift_certificate_id
	from ec_gift_certificates g
	where gift_certificate_state='authorized'
	and (0=(select count(*) 
            from ec_automatic_email_log log 
            where log.gift_certificate_id=g.gift_certificate_id 
            and email_template_id=4))" {
	ec_email_new_gift_certificate_order $gift_certificate_id
    }
}

ad_proc ec_send_unsent_gift_certificate_recipient_email {} {
 
   Finds authorized gift certificates for which email
   has not been sent to the recipient, sends the email, and records
   that it has been sent.

} {
    db_foreach certificates_select "
	select gift_certificate_id
	from ec_gift_certificates g
	where gift_certificate_state='authorized'
	and (0=(select count(*) 
	    from ec_automatic_email_log log 
	    where log.gift_certificate_id=g.gift_certificate_id 
	    and email_template_id=5))" {
	ec_email_gift_certificate_recipient $gift_certificate_id
    }
}

ad_proc ec_delayed_credit_denied {
}  { 

    Sends "Credit Denied" email to consumers whose authorization was
    initially inconclusive and then failed, and then saves the order
    for them (so that consumer can go back to site and retry the
    authorization).

} {
    set order_id_list [db_list denied_orders_select "
	select order_id 
	from ec_orders 
	where order_state='failed_authorization'"]

    foreach order_id $order_id_list {

	ns_log notice "ec_delayed_credit_denied working on order #$order_id"

	# Save this shopping cart for the user

	db_dml order_state_update "
	    update ec_orders 
	    set order_state='in_basket', saved_p='t' 
	    where order_id=:order_id"

	ec_email_delayed_credit_denied $order_id
    }
}

ad_proc ec_expire_old_carts {
} { 

    Expires old carts.

} {
    set cart_duration [ad_parameter -package_id [ec_id] CartDuration ecommerce]
    db_transaction {
	db_dml expired_carts_update "
            update ec_orders 
            set order_state='expired', expired_date=sysdate 
            where order_state='in_basket' 
            and sysdate-in_basket_date > :cart_duration"
	db_dml item_state_update "
            update ec_items 
            set item_state='expired', expired_date=sysdate 
            where item_state='in_basket' 
            and order_id in (select order_id 
                from ec_orders 
                where order_state='expired')"
    }
}

ad_proc ec_remove_creditcard_data {
} { 

    Remove credit card number from ec_creditcards if package
    parameter SaveCreditCardDataP = 0. Ec_remove_creditcard_data
    removes only the credit card numbers for the cards whose numbers
    are no longer needed (i.e. all their orders are fulfilled,
    returned, void, or expired). The last four digits -also stored in
    ec_creditcards- remain.

} {
    if { [ad_parameter -package_id [ec_id] SaveCreditCardDataP ecommerce] == 0 } {
	db_dml creditcard_update "
	    update ec_creditcards
	    set creditcard_number=null
	    where creditcard_id in (select unique c.creditcard_id
		from ec_creditcards c, ec_orders o
		where c.creditcard_id = o.creditcard_id
		and c.creditcard_number is not null
		and 0=(select count(*)
		    from ec_orders o2
		    where o2.creditcard_id=c.creditcard_id
		    and o2.order_state not in ('fulfilled','returned','void','expired'))
		and 0=(select count(*)
		    from ec_financial_transactions
		    where transaction_type = 'refund'
		    and refunded_date is null))"
    }
}

ad_proc ec_unauthorized_transactions {
} { 

    Ec_unauthorized_transactions searches for unauthorized transactions
    whose to_be_captured_date is over 1/2 hr old and authorized_date is
    null this is similar to ec_sweep_for_payment_zombies except that in
    this case these are shipments that are unauthorized.

} {

    # Lookup the selected currency.

    set currency [ad_parameter Currency ecommerce]

    # Lookup the selected payment gateway

    set payment_gateway [ad_parameter PaymentGateway -default [ad_parameter -package_id [ec_id] PaymentGateway]]
    if {[empty_string_p $payment_gateway]} {
	    ns_log warning "ec_unauthorized_transactions: No payment gateway has been selected."
	    return
    } else {
	if {![acs_sc_binding_exists_p "PaymentGateway" $payment_gateway]} {
	    ns_log warning "ec_unauthorized_transactions: Payment gateway $payment_gateway is not bound to the Payment Service Contract."
	    return
	}
    }

    db_foreach transactions_select "
        select f.transaction_id, f.order_id, f.transaction_amount, f.to_be_captured_date, 
            p.first_names || ' ' || p.last_name as card_name, 
            substring(creditcard_expire for 2) as card_exp_month, substring(creditcard_expire from 4 for 2) as card_exp_year, c.creditcard_number as card_number, c.creditcard_type,
            a.zip_code as billing_zip,
            a.line1 as billing_address, 
	    a.city as billing_city, 
            coalesce(a.usps_abbrev, a.full_state_name) as billing_state, 
            a.country_code as billing_country
        from ec_financial_transactions f, ec_creditcards c, persons p, ec_addresses a
	where to_be_captured_p='t'
	and sysdate-to_be_captured_date > 1/48
	and authorized_date is null
	and failed_p='f'
        and f.creditcard_id=c.creditcard_id 
        and c.user_id=p.person_id
	and c.billing_address = a.address_id" {

	ns_log notice "ec_unauthorized_transactions working on transaction $transaction_id"

	# Convert the one digit creditcard abbreviation to the
	# standardized name of the card.

	set card_type [ec_pretty_creditcard_type $creditcard_type]

	# Connect to the payment gateway to authorize the transaction.

	array set response [acs_sc_call "PaymentGateway" "Authorize" \
				[list $transaction_id \
				     $transaction_amount \
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
	# human readable description of the response and the transaction
	# id is the ID as returned by the payment gateway.

	set response_code $response(response_code)
	set reason $response(reason)
	set pgw_transaction_id $response(transaction_id)

	# Interpret the response_code.

	switch -exact $response_code {
	    
	    "failure" -
	    "not_supported" -
	    "not_implemented" - 
	    default {

		# The payment gateway rejected to authorize the
		# transaction, can not authorize any transaction.

		# Flag the transaction as failed and log the problem
		# in the ecommerce problem log for the administrator.

		db_transaction {
		    db_dml transaction_failed_update "
			update ec_financial_transactions 
			set failed_p = 't' 
			where transaction_id = :transaction_id"
		    set problem_details "The authorization failed for transaction_id $transaction_id for the following reason: $reason"
		    db_dml problems_log_insert "
			insert into ec_problems_log
			(problem_id, problem_date, problem_details, order_id)
			values
			(ec_problem_id_sequence.nextval, sysdate, :problem_details, :order_id)"
		}
	    }
	    
	    "failure-retry" {

		# The response_code is failure-retry, this means there
		# was a temporary failure that can be retried. Fail
		# the transaction however, if the order was authorized
		# a while ago (as defined in package parameter
		# PaymentRetryPeriod) the temporary failure turns out
		# to be less 'temporary'.

		if { [expr [dt_interval_check $to_be_captured_date [clock format [clock seconds] -format "%D %H:%M:%S"]] / (60 * 60) ] > \
			 [ad_parameter PaymentRetryPeriod -default [ad_parameter -package_id [ec_id] PaymentRetryPeriod]] } {

		    db_transaction {

			# Flag the transaction as failed so that it
			# will not be retried.

			db_dml transaction_failure_update "
			    update ec_financial_transactions
			    set failed_p = 't'
			    where transaction_id=:transaction_id"

			# Log this failure in the problem log.

			set problem_details "Transaction $transaction_id failed to mark due to repeated 'failure-retry' reponses from the payment gateway"
			db_dml problems_log_insert "
			    insert into ec_problems_log
			    (problem_id, problem_date, problem_details, order_id)
			    values
			    (ec_problem_id_sequence.nextval, sysdate, :problem_details, :order_id)"
		    }
		} else {

		    # Leave the order as is so that the order will be
		    # retried the next time this procedure is run.

		}
	    }

	    "success" {

		# The payment gateway authorized the
		# transaction. Update the # transaction.

		db_dml transaction_success_update "
		    update ec_financial_transactions 
		    set transaction_id = :pgw_transaction_id, authorized_date=sysdate 
		    where transaction_id=:transaction_id"
	    }
	}
    } 
}

ad_proc ec_unmarked_transactions {
} {
 
    unmarked transactions 
    to_be_captured_p is 't' and authorized_date is not null and marked_date is null

} {

    # Lookup the selected currency.

    set currency [ad_parameter Currency ecommerce]

    # Lookup the selected payment gateway

    set payment_gateway [ad_parameter PaymentGateway -default [ad_parameter -package_id [ec_id] PaymentGateway]]
    if {[empty_string_p $payment_gateway]} {
	    ns_log warning "ec_unmarked_transactions: No payment gateway has been selected."
	    return	
    } else {
	if {![acs_sc_binding_exists_p "PaymentGateway" $payment_gateway]} {
	    ns_log warning "ec_unmarked_transactions: Payment gateway $payment_gateway is not bound to the Payment Service Contract."
	    return
	}
    }

    db_foreach transactions_select "
        select f.transaction_id, f.order_id, f.transaction_amount, f.to_be_captured_date,
            p.first_names || ' ' || p.last_name as card_name, 
	    c.creditcard_number as card_number,  c.creditcard_type, substring(creditcard_expire for 2) as card_exp_month, substring(creditcard_expire from 4 for 2) as card_exp_year,
            a.zip_code as billing_zip,
            a.line1 as billing_address, 
	    a.city as billing_city, 
            coalesce(a.usps_abbrev, a.full_state_name) as billing_state, 
            a.country_code as billing_country
        from ec_financial_transactions f, ec_creditcards c, persons p, ec_addresses a
	where to_be_captured_p='t'
	and marked_date is null
	and f.failed_p='f'
        and f.creditcard_id=c.creditcard_id 
        and c.user_id=p.person_id
	and c.billing_address = a.address_id" {

	ns_log notice "ec_unmarked_transactions working on transaction $transaction_id"

	# Convert the one digit creditcard abbreviation to the
	# standardized name of the card.

	set card_type [ec_pretty_creditcard_type $creditcard_type]

	# Connect to the payment gateway to authorize the transaction.

	array set response [acs_sc_call "PaymentGateway" "ChargeCard" \
				[list $transaction_id \
				     $transaction_amount \
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
	# human readable description of the response and the transaction
	# id is the ID as returned by the payment gateway.

	set response_code $response(response_code)
	set reason $response(reason)
	set pgw_transaction_id $response(transaction_id)

	# Interpret the response_code.

	switch -exact $response_code {
	    
	    "failure" -
	    "not_supported" -
	    "not_implemented" -
	    default {

		# The payment gateway rejected to post authorize the
		# transaction, can not post authorize any
		# transaction. Or the gateway returned an unknown
		# response_code.

		# Flag the transaction as failed and log the problem
		# in the ecommerce problem log for the administrator.

		db_transaction {
		    db_dml transaction_failed_update "
			update ec_financial_transactions 
			set failed_p='t' 
			where transaction_id=:transaction_id"
		    set problem_details "The post authorization failed for transaction_id $transaction_id for the following reason: $reason"
		    db_dml problems_log_insert "
			insert into ec_problems_log
			(problem_id, problem_date, problem_details, order_id)
			values
			(ec_problem_id_sequence.nextval, sysdate, :problem_details, :order_id)"
		}
	    }
	    
	    "failure-retry" {

		# The response_code is failure-retry, this means there
		# was a temporary failure that can be retried. Fail
		# the transaction however, if the order was authorized
		# a while ago (as defined in package parameter
		# PaymentRetryPeriod) the temporary failure turns out
		# to be less 'temporary'.

		if { [expr [dt_interval_check $to_be_captured_date [clock format [clock seconds] -format "%D %H:%M:%S"]] / (60 * 60) ] > \
			 [ad_parameter PaymentRetryPeriod -default [ad_parameter -package_id [ec_id] PaymentRetryPeriod]] } {

		    db_transaction {

			# Flag the transaction as failed so that it
			# will not be retried.

			db_dml transaction_failure_update "
			    update ec_financial_transactions
			    set failed_p = 't'
			    where transaction_id=:transaction_id"

			# Log this failure in the problem log.

			set problem_details "Transaction $transaction_id failed to mark due to repeated 'failure-retry' reponses from the payment gateway"
			db_dml problems_log_insert "
			    insert into ec_problems_log
			    (problem_id, problem_date, problem_details, order_id)
			    values
			    (ec_problem_id_sequence.nextval, sysdate, :problem_details, :order_id)"
		    }
		} else {

		    # Leave the order as is so that the order will be
		    # retried the next time this procedure is run.

		}
	    }

	    "success" {

		# The payment gateway approved the transaction. Update
		# the transaction. The gateway returns a new
		# transaction_id when ChargeCard resulted in a new
		# transaction rather than the next step in processing
		# an existing transaction.

		if { [empty_string_p $pgw_transaction_id] } {
		    set pgw_transaction_id $transaction_id
		}
		db_dml transaction_success_update "
		    update ec_financial_transactions 
		    set transaction_id = :pgw_transaction_id, marked_date=sysdate 
		    where transaction_id=:transaction_id"
	    }
	}
    }
}

ad_proc ec_unrefunded_transactions {
} { 

    Unrefunded transactions. Transaction_type is 'refund' and
    inserted_date is over 1/2 hr old and refunded_date is null

} {

    # Lookup the selected currency.

    set currency [ad_parameter Currency ecommerce]

    # Lookup the selected payment gateway

    set payment_gateway [ad_parameter PaymentGateway -default [ad_parameter -package_id [ec_id] PaymentGateway]]
    if {[empty_string_p $payment_gateway]} {
	    ns_log warning "ec_unrefunded_transactions: No payment gateway has been selected."
	    return	
    } else {
	if {![acs_sc_binding_exists_p "PaymentGateway" $payment_gateway]} {
	    ns_log warning "ec_unrefunded_transactions: Payment gateway $payment_gateway is not bound to the Payment Service Contract."
	    return
	}
    }

    db_foreach transactions_select "
        select f.transaction_id, f.order_id, f.transaction_amount, f.to_be_captured_date, c.creditcard_type as card_type, 
            p.first_names || ' ' || p.last_name as card_name, c.creditcard_number as card_number, 
            c.creditcard_expire as card_expiration, c.creditcard_type
            a.zip_code as billing_zip,
	    a.line1 as billing_address, 
	    a.city as billing_city, 
            nsvl(a.usps_abbrev, a.full_state_name) as billing_state, 
            a.country_code as billing_country
        from ec_financial_transactions f, ec_creditcards c, persons p, ec_addresses a 
	where transaction_type = 'refund'
	and f.refunded_date is null
	and f.failed_p='f'
        and f.creditcard_id = c.creditcard_id 
        and c.user_id = p.person_id
	and c.billing_address = a.address_id
	and sysdate-to_be_captured_date > 1/48" {

        ns_log notice "ec_unrefunded_transactions working on transaction $transaction_id"
	    
	# Convert the one digit creditcard abbreviation to the
	# standardized name of the card.

	set card_type [ec_pretty_creditcard_type $creditcard_type]

	# Connect to the payment gateway to authorize the transaction.

	array set response [acs_sc_call "PaymentGateway" "Return" \
				[list $marked_transaction_id \
				     $transaction_amount \
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
	# human readable description of the response and the transaction
	# id is the ID as returned by the payment gateway.

	set response_code $response(response_code)
	set reason $response(reason)
	set pgw_transaction_id $response(transaction_id)

	# Interpret the response_code.

	switch -exact $response_code {
	    
	    "failure" -
	    "not_supported" -
	    "not_implemented" -
	    default {

		# The payment gateway rejected to refund the
		# transaction, can not refund any transactions. Or
		# returned an unknown response_code.

		# Flag the transaction as failed and log the problem
		# in the ecommerce problem log for the administrator.

		db_transaction {
		    db_dml transaction_failed_update "
			update ec_financial_transactions 
			set failed_p='t' 
			where transaction_id=:transaction_id"
		    set problem_details "The refund failed for transaction_id $transaction_id for the following reason: $reason"
		    db_dml problems_log_insert "
			insert into ec_problems_log
			(problem_id, problem_date, problem_details, order_id)
			values
			(ec_problem_id_sequence.nextval, sysdate, :problem_details, :order_id)"
		}

	    }

	    "failure-retry" {

		# The response_code is failure-retry, this means there
		# was a temporary failure that can be retried. Fail
		# the transaction however, if the order was authorized
		# a while ago (as defined in package parameter
		# PaymentRetryPeriod) the temporary failure turns out
		# to be less 'temporary'.

		if { [expr [dt_interval_check $to_be_captured_date [clock format [clock seconds] -format "%D %H:%M:%S"]] / (60 * 60) ] > \
			 [ad_parameter PaymentRetryPeriod -default [ad_parameter -package_id [ec_id] PaymentRetryPeriod]] } {

		    db_transaction {

			# Flag the transaction as failed so that it
			# will not be retried.

			db_dml transaction_failure_update "
			    update ec_financial_transactions
			    set failed_p = 't'
			    where transaction_id=:transaction_id"

			# Log this failure in the problem log.

			set problem_details "Transaction $transaction_id failed to mark due to repeated 'failure-retry' reponses from the payment gateway"
			db_dml problems_log_insert "
			    insert into ec_problems_log
			    (problem_id, problem_date, problem_details, order_id)
			    values
			    (ec_problem_id_sequence.nextval, sysdate, :problem_details, :order_id)"
		    }
		} else {

		    # Leave the order as is so that the order will be
		    # retried the next time this procedure is run.

		}
	    }

	    "success" {
		
		# The payment gateway refunded the transaction. Update
		# the transaction.

		db_dml transaction_success_update "
		    update ec_financial_transactions 
		    set refunded_date=sysdate, transaction_id = :pgw_transaction_id 
		    where transaction_id=:transaction_id"
	    }
	}
    }
}
