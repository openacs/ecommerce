ad_page_contract {

    @author Eve Andersson (eveander@arsdigita.com)
    @creation-date Summer 1999
    @author ported by Jerry Asher (jerry@theashergroup.com)

    @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @revision-date April 2002

} {
    shipment_id:integer,notnull
    order_id:integer,notnull
    shipment_date:notnull
    expected_arrival_date
    carrier:optional
    carrier_other:optional
    tracking_number:optional
    item_id
}

ad_require_permission [ad_conn package_id] admin

set item_id_list $item_id

# 1. Add a row to ec_shipments.

# 2. Update item_state and shipment_id in ec_items.

# 3. Compute how much to charge the customer. The shipment can be a
#    pratial shipment, products can have been added to or removed from
#    the order after the original order was approved

#    (a) If the total amount is the same as the amount previously
#        calculated for the entire order, then update to_be_captured_p
#        and to_be_captured_date in ec_financial_transactions and try
#        to mark the transaction*

#    (b) If the total amount is different and greater than 0:
#        I.    add a row to ec_financial_transactions with
#              to_be_captured_p and to_be_captured_date set
#        II.   do a new authorization*
#        III.  mark transaction*

# The customer service rep must be logged on

ad_maybe_redirect_for_registration
set customer_service_rep [ad_verify_and_get_user_id]

# Doubleclick protection

if { [db_string doubleclick_select "
	select count(*) 
	from ec_shipments 
	where shipment_id=:shipment_id"] > 0 } {
    ad_returnredirect "fulfillment"
    ad_script_abort
}

set shipping_method [db_string shipping_method_select "
   select shipping_method 
   from ec_orders 
    where order_id=:order_id"]

set shippable_p [ec_decode [db_string shippable_p_select "
    select shipping_method 
    from ec_orders 
    where order_id=:order_id"] "no shipping" 0 1]

# 0. Calculate shipment tax charged. Start by calculating the shipping
#    cost.

set item_id_vars [list]
foreach item_id $item_id_list {
    set var_name "item_id_[llength $item_id_vars]"
    set $var_name $item_id
    lappend item_id_vars ":$var_name"
}

set total_price_of_items [db_string total_price_of_items_select "
    select nvl(sum(price_charged),0) 
    from ec_items
    where item_id in ([join $item_id_list ", "])"]

# Calculate the total shipping cost of the shipment.

if { $shippable_p } {

    # See if base shipping cost should be included in
    # total_shipping_of_items

    set n_shipments_already [db_string n_shipments_already_select "
	select count(*) 
	from ec_shipments
	where order_id=:order_id"]
    
    set shipping_of_items [db_string shipping_of_items_select "
	select nvl(sum(shipping_charged),0) 
	from ec_items
	where item_id in ([join $item_id_list ", "])"]

    if { $n_shipments_already == 0 } {
	set total_shipping_of_items [db_string total_shipping_of_items_select "
	    select $shipping_of_items + shipping_charged 
	    from ec_orders 
	    where order_id=:order_id"]
    } else {
	set total_shipping_of_items $shipping_of_items
    }
} else {

    # It's a pickup order

    set total_shipping_of_items 0
    set expected_arrival_date ""
    set carrier ""
    set tracking_number ""
}

set total_tax_of_items [db_string total_tax_of_items_select "
    select ec_tax(:total_price_of_items, :total_shipping_of_items, :order_id)
    from dual"]

set peeraddr [ns_conn peeraddr]
set shippable_p_tf [ec_decode $shippable_p 0 f t]

db_dml insert_shipment_info "
    insert into ec_shipments
    (shipment_id, order_id, shipment_date, expected_arrival_date, carrier, tracking_number, shippable_p, last_modified, last_modifying_user, modified_ip_address)
    values
    (:shipment_id, :order_id, to_date(:shipment_date, 'YYYY-MM-DD HH12:MI:SSAM'), 
     to_date(:expected_arrival_date, 'YYYY-MM-DD HH12:MI:SSAM'), :carrier, :tracking_number, :shippable_p_tf, sysdate, :customer_service_rep, :peeraddr)"

db_dml item_state_update "
    update ec_items
    set item_state='shipped', shipment_id=:shipment_id
    where item_id in ([join $item_id_list ", "])"

# Calculate the total shipment cost (price + shipping + tax - gift
# certificate) of the shipment

set shipment_cost [db_string shipment_cost_select "
		       select ec_shipment_cost(:shipment_id) 
		       from dual"]

# No financial transactions need to be update when the shipment is
# for free.

if { $shipment_cost >= 0 } {

    # Calculate the total order cost (price + shipping + tax -
    # gift_certificate) so we'll know if we can use the original
    # transaction

    set hard_goods_total_cost [db_string hard_goods_cost_select "
	select coalesce(sum(i.price_charged),0) - coalesce(sum(i.price_refunded),0) + 
	    coalesce(sum(i.price_tax_charged),0) - coalesce(sum(i.shipping_refunded),0) +
            coalesce(sum(i.shipping_charged),0) - coalesce(sum(i.shipping_refunded),0)  + 
	    coalesce(sum(i.shipping_tax_charged),0) - coalesce(sum(i.shipping_tax_refunded),0)
	from ec_items i, ec_products p
	where i.order_id = :order_id
	and i.item_state <> 'void'
	and i.product_id = p.product_id
	and p.no_shipping_avail_p = 'f'"]
    set order_shipping [db_string get_order_shipping "
	select coalesce(shipping_charged, 0)
	from ec_orders
	where order_id = :order_id"]
    set order_shipping_tax [db_string get_order_shipping_tax "
	select ec_tax(0, :order_shipping, :order_id)"]
    set order_cost [expr $hard_goods_total_cost + $order_shipping + $order_shipping_tax]

    # Verify that the shipment is for the entire order.

    if {$shipment_cost == $order_cost} {

	# The shipment could be for the entire order but it could also
	# be that a partial shipment, return, and an addition of more
	# items to the order by the site administrator maked the
	# order_cost equal the shipment_cost.

	# Get the amount that was authorized when the user placed the
	# order. It could be that the customer instructed the
	# administrator to add items to or remove items from the
	# order. The transaction can only be marked for settlement if
	# the shipment cost equals the authorized amount.

	# Bart Teeuwisse: Many (all?) credit card gateways can settle
	# a lower amount than the amount authorized but the ecommerce
	# package is designed to always settle the authorized
	# amount. ec_financial_transactions only stores 1 transaction
	# amount and can thus not differentiate between the amount
	# authorized and the amount to capture.

	if {[string equal $shipment_cost [db_string authorized_amount_select "
	    select transaction_amount
	    from ec_financial_transactions
	    where order_id = :order_id
	    and to_be_captured_p is null
            and authorized_date is not null
	    and transaction_type = 'charge'" -default ""]]} {

	    set transaction_id [db_string transaction_id_select "
		select transaction_id
		from ec_financial_transactions 
		where order_id = :order_id
		and to_be_captured_p is null
		and transaction_type = 'charge'" -default ""]
	    
	    if { ![empty_string_p $transaction_id] } {
		db_dml transaction_update "
		    update ec_financial_transactions 
		    set shipment_id=:shipment_id, to_be_captured_p='t', to_be_captured_date=sysdate
		    where transaction_id=:transaction_id"
		
		# Mark the transaction

		array set response [ec_creditcard_marking $transaction_id]
		set mark_result $response(response_code)
		set pgw_transaction_id $response(transaction_id)
		if { [string equal $mark_result "invalid_input"]} {
		    set problem_details "When trying to mark shipment $shipment_id (transaction $transaction_id) at [ad_conn url], the following result occurred: $mark_result"
		    db_dml problems_log_insert "
			insert into ec_problems_log
			(problem_id, problem_date, problem_details, order_id)
			values
			(ec_problem_id_sequence.nextval, sysdate, :problem_details, :order_id)"
		} elseif {[string equal $mark_result "success"]} {
		    db_dml transaction_success_update "
			update ec_financial_transactions 
			set marked_date=sysdate
			where transaction_id = :pgw_transaction_id"
		}

		# The shipment is a partial shipment but the shipment
		# cost equals the order cost. This could be due to
		# voiding of items. A new transaction is required if
		# there are no more items awaiting shipment and this
		# shipment thus completes the order.

		if {[string equal 0 [db_string count_remaining_items "
		    select count(*)
		    from ec_items
		    where order_id = :order_id
		    and item_state = 'to_be_shipped'
		    and item_id not in ([join $item_id_list ", "])" -default 0]]} {
		    set create_new_transaction true
		} else {
		    set create_new_transaction false
		}
	    }
	} else {
	    
	    # The shipment is a partial shipment but the
	    # shipment cost equals the order cost. 

	    set create_new_transaction false
	}
    } else {
	set create_new_transaction true
    }

    # Create new financial transactions as needed and process them.

    if { $create_new_transaction } {

	# 1. add a row to ec_financial_transactions with
	#    to_be_captured_p and to_be_captured_date set
	# 2. do a new authorization
	# 3. mark transaction
	
	# Get id for the new transaction.

	set transaction_id [db_nextval ec_transaction_id_sequence]
	db_dml transaction_insert "
		insert into ec_financial_transactions
      		(transaction_id, order_id, shipment_id, transaction_amount, transaction_type, to_be_captured_p, inserted_date, to_be_captured_date)
      		values
      		(:transaction_id, :order_id, :shipment_id, :shipment_cost, 'charge', 't', sysdate, sysdate)"

	# Authorize the transaction, ec_creditcard_authorization
	# returns failed_authorization, authorized,
	# no_recommendation, or invalid_input.

	array set response [ec_creditcard_authorization $order_id $transaction_id]
	set result $response(response_code)
	set pgw_transaction_id $response(transaction_id)
	if {[string equal $result "failed_authorization"] || [string equal $result "invalid_input"]} {
	    set problem_details "When trying to authorize shipment $shipment_id (transaction $transaction_id) at [ad_conn url], the following result occurred: $result"
	    db_dml problems_insert "
		    insert into ec_problems_log
		    (problem_id, problem_date, problem_details, order_id)
		    values
		    (ec_problem_id_sequence.nextval, sysdate, :problem_details, :order_id)"

	    if { [ad_parameter -package_id [ec_id] DisplayTransactionMessagesDuringFulfillmentP ecommerce] } {
		ad_return_warning "Credit Card Failure" "
		    <p>Warning: the credit card authorization for this shipment (shipment_id $shipment_id) of order_id $order_id failed.</p>
		    <p>You may wish to abort the shipment (if possible) until this is issue is resolved. A note has been made in the problems log.</p>
		    <p><a href=\"fulfillment\">Continue with order fulfillment.</a></p>"
                ad_script_abort
	    }
	    if {[string equal $result "failed_p"]} {
		db_dml transaction_failed_update "
			update ec_financial_transactions 
			set failed_p='t' 
			where transaction_id=:transaction_id"
	    }
	} elseif {[string equal $result "authorized"]} {

	    # Put authorized_date into ec_financial_transacions.

	    db_dml transaction_authorized_update "
			update ec_financial_transactions
			set authorized_date=sysdate 
			where transaction_id=:pgw_transaction_id"

	    # Mark the transaction.

	    array set response [ec_creditcard_marking $pgw_transaction_id]
	    set mark_result $response(response_code)
	    set pgw_transaction_id $response(transaction_id)
	    if {[string equal $mark_result "invalid_input"]} {
		set problem_details "When trying to mark shipment $shipment_id (transaction $transaction_id) at [ad_conn url], the following result occurred: $mark_result"
		db_dml problems_insert "
			insert into ec_problems_log
	  		(problem_id, problem_date, problem_details, order_id)
	  		values
	  		(ec_problem_id_sequence.nextval, sysdate, :problem_details, :order_id)"
	    } elseif {[string equal $mark_result "success"]} {
		db_dml transaction_success_update "
			update ec_financial_transactions 
			set marked_date = sysdate
			where transaction_id=:pgw_transaction_id"
	    }
	}
    }
}

# Send the "Order Shipped" email if it was a shippable order

if { $shippable_p } {
    ec_email_order_shipped $shipment_id
}
ad_returnredirect "fulfillment"
