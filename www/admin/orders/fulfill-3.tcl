# /www/[ec_url_concat [ec_url] /admin]/orders/fulfill-3.tcl
ad_page_contract {

    @author Eve Andersson (eveander@arsdigita.com)
    @creation-date Summer 1999
    @cvs-id fulfill-3.tcl,v 3.4.2.6 2000/08/18 21:46:57 stevenp Exp
    @author ported by Jerry Asher (jerry@theashergroup.com)
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


# We have to:
# 1. Add a row to ec_shipments.
# 2. Update item_state and shipment_id in ec_items.
# 3. Compute how much we need to charge the customer
#    (a) If the total amount is the same as the amount previously calculated
#        for the entire order, then update to_be_captured_p and to_be_captured_date
#        in ec_financial_transactions and try to mark the transaction*
#    (b) If the total amount is different and greater than 0:
#        I.  add a row to ec_financial_transactions with
#             to_be_captured_p and to_be_captured_date set
#        II. do a new authorization*
#        III.  mark transaction*

# * I was debating with myself whether it really makes sense to do the CyberCash
# transactions on this page since, by updating to_be_captured_* in
# ec_financial_transactions, a cron job can easily come around later and
# see what needs to be done.
# Pros: (1) instant feedback, if desired, if the transaction fails, which means the
#           shipment can possibly be aborted
#       (2) if it were done via a cron job, the cron job would need to query CyberCash
#           first to see if CyberCash had a record for the transaction before it could
#           try to auth/mark it (in case we had attempted the transaction before an got
#           an inconclusive result), whereas on this page there's no need to query first
#           (you know CyberCash doesn't have a record for it).  CyberCash charges 20
#           cents per transaction, although I don't actually know if a query is considered
#           a transaction.
# Cons: it slows things down for the person recording shipments

# I guess I'll just do the transactions on this page, for now, and if they prove too
# slow they can be taken out without terrible consequences (the cron job has to run
# anyway in case the results here are inconclusive).

# the customer service rep must be logged on
ad_maybe_redirect_for_registration
set customer_service_rep [ad_verify_and_get_user_id]

# doubleclick protection
if { [db_string doubleclick_select "select count(*) from ec_shipments where shipment_id=:shipment_id"] > 0 } {
    ad_returnredirect "fulfillment"
    return
}

set shipping_method [db_string shipping_method_select "select shipping_method from ec_orders where order_id=:order_id"]

set shippable_p [ec_decode [db_string shippable_p_select "select shipping_method from ec_orders where order_id=:order_id"] "no shipping" 0 1]

# 0. Calculate shipment tax charged.

set item_id_vars [list]
foreach item_id $item_id_list {
    set var_name "item_id_[llength $item_id_vars]"
    set $var_name $item_id
    lappend item_id_vars ":$var_name"
}

set total_price_of_items [db_string total_price_of_items_select "select nvl(sum(price_charged),0) from ec_items where item_id in ([join $item_id_vars ", "])"]

if { $shippable_p } {
    # see if base shipping cost should be included in total_shipping_of_items
    set n_shipments_already [db_string n_shipments_already_select "select count(*) from ec_shipments where order_id=:order_id"]
    
    set shipping_of_items [db_string shipping_of_items_select "select nvl(sum(shipping_charged),0) from ec_items where item_id in ([join $item_id_vars ", "])"]
    
    if { $n_shipments_already == 0 } {
	set total_shipping_of_items [db_string total_shipping_of_items_select "select $shipping_of_items + shipping_charged from ec_orders where order_id=:order_id"]
    } else {
	set total_shipping_of_items $shipping_of_items
    }
} else {
    # it's a pickup order
    set total_shipping_of_items 0
    set expected_arrival_date ""
    set carrier ""
    set tracking_number ""
}

set total_tax_of_items [db_string total_tax_of_items_select "select ec_tax(:total_price_of_items, :total_shipping_of_items, :order_id) from dual"]

set peeraddr [ns_conn peeraddr]
set shippable_p_tf [ec_decode $shippable_p 0 f t]

db_transaction {
    db_dml insert_shipment_info "insert into ec_shipments
  (shipment_id, order_id, shipment_date, expected_arrival_date, carrier, tracking_number, shippable_p, last_modified, last_modifying_user, modified_ip_address)
  values
  (:shipment_id, :order_id, to_date(:shipment_date, 'YYYY-MM-DD HH12:MI:SSAM'), to_date(:expected_arrival_date, 'YYYY-MM-DD HH12:MI:SSAM'), :carrier, :tracking_number, :shippable_p_tf, sysdate, :customer_service_rep, :peeraddr)
  "

    db_dml item_state_update "
  update ec_items
  set item_state='shipped', shipment_id=:shipment_id
  where item_id in ([join $item_id_vars ", "])
  "

    # calculate the total shipment cost (price + shipping + tax - gift certificate) of the shipment
    set shipment_cost [db_string shipment_cost_select "select ec_shipment_cost(:shipment_id) from dual"]

    # calculate the total order cost (price + shipping + tax - gift_certificate) so we'll
    # know if we can use the original transaction
    set order_cost [db_string order_cost_select "select ec_order_cost(:order_id) from dual"]

    # It is conceivable, albeit unlikely, that a partial shipment,
    # return, and an addition of more items to the order by the site
    # administrator can make the order_cost equal the shipment_cost
    # even if it isn't the first shipment, which is fine.  But if
    # this happens twice, this would have caused the system (which is
    # trying to minimize financial transactions) to try to reuse an old
    # transaction, which will fail, so I've added the 2nd half of the
    # "if statement" below to make sure that transaction doesn't get reused:

    if { $shipment_cost == $order_cost && [db_string to_be_captured_p_select "select count(*) from ec_financial_transactions where order_id=:order_id and to_be_captured_p='t'"] == 0} {
	set transaction_id [db_string transaction_id_select "select max(transaction_id) from ec_financial_transactions where order_id=:order_id"]
	# 1999-08-11: added shipment_id to the update
	
	# 1999-08-29: put the update inside an if statement in case there is
	# no transaction to update
	if { ![empty_string_p $transaction_id] } {
	    db_dml transaction_update "update ec_financial_transactions set shipment_id=:shipment_id, to_be_captured_p='t', to_be_captured_date=sysdate where transaction_id=:transaction_id"
	}

	# try to mark the transaction
	# 1999-08-29: put the marking inside an if statement in case there is
	# no transaction to update
	if { ![empty_string_p $transaction_id] } {

	    set cc_mark_result [ec_creditcard_marking $transaction_id]
	    if { $cc_mark_result == "invalid_input" } {
		set problem_details "When trying to mark shipment $shipment_id (transaction $transaction_id) at [ad_conn url], the following result occurred: $cc_mark_result"
		db_dml problems_log_insert "insert into ec_problems_log
	(problem_id, problem_date, problem_details, order_id)
	values
	(ec_problem_id_sequence.nextval, sysdate, :problem_details, :order_id)
	"
	    } elseif { $cc_mark_result == "success" } {
		db_dml transaction_success_update "update ec_financial_transactions set marked_date=sysdate where transaction_id=:transaction_id"
	    }
	}
    } else {
	if { $shipment_cost >= 0 } {
	    # 1. add a row to ec_financial_transactions with to_be_captured_p and to_be_captured_date set
	    # 2. do a new authorization
	    # 3. mark transaction
	    
	    # Note: 1 is the only one we want to do inside the transaction; if 2 & 3 fail, they will be
	    # tried later with a cron job (they involve talking to CyberCash, so you never know what will
	    # happen with them)
	    
	    # Get id for the new transaction.
	    set transaction_id [db_nextval ec_transaction_id_sequence]
	    # 1999-08-11: added shipment_id to the insert
	    
	    db_dml transaction_insert "insert into ec_financial_transactions
      (transaction_id, order_id, shipment_id, transaction_amount, transaction_type, to_be_captured_p, inserted_date, to_be_captured_date)
      values
      (:transaction_id, :order_id, :shipment_id, :shipment_cost, 'charge','t',sysdate, sysdate)
      "

	    # CyberCash stuff
	    # this attempts an auth and returns failed_authorization, authorized_plus_avs, authorized_minus_avs, no_recommendation, or invalid_input
	    set cc_result [ec_creditcard_authorization $order_id $transaction_id]
	    if { $cc_result == "failed_authorization" || $cc_result == "invalid_input" } {
		set problem_details "When trying to authorize shipment $shipment_id (transaction $transaction_id) at [ad_conn url], the following result occurred: $cc_result"
		db_dml problems_insert "
	insert into ec_problems_log
	(problem_id, problem_date, problem_details, order_id)
	values
	(ec_problem_id_sequence.nextval, sysdate, :problem_details, :order_id)
	"

		if { [util_memoize {ad_parameter -package_id [ec_id] DisplayTransactionMessagesDuringFulfillmentP ecommerce} [ec_cache_refresh]] } {
		    ad_return_warning "Credit Card Failure" "Warning: the credit card authorization for this shipment (shipment_id $shipment_id) of order_id $order_id failed.  You may wish to abort the shipment (if possible) until this is issue is resolved.  A note has been made in the problems log.<p><a href=\"fulfillment\">Continue with order fulfillment.</a>"
		    return
		}
		if { $cc_result == "failed_p" } {
		    db_dml transaction_failed_update "update ec_financial_transactions set failed_p='t' where transaction_id=:transaction_id"
		}
	    } elseif { $cc_result == "authorized_plus_avs" || $cc_result == "authorized_minus_avs" } {
		# put authorized_date into ec_financial_transacions
		db_dml transaction_authorized_udpate "update ec_financial_transactions set authorized_date=sysdate where transaction_id=:transaction_id"
		# try to mark the transaction
		set cc_mark_result [ec_creditcard_marking $transaction_id]
		ns_log Notice "fulfill-3.tcl: cc_mark_result is $cc_mark_result"
		if { $cc_mark_result == "invalid_input" } {
		    set problem_details "When trying to mark shipment $shipment_id (transaction $transaction_id) at [ad_conn url], the following result occurred: $cc_mark_result"
		    db_dml problems_insert "insert into ec_problems_log
	  (problem_id, problem_date, problem_details, order_id)
	  values
	  (ec_problem_id_sequence.nextval, sysdate, :problem_details, :order_id)
	  "
		} elseif { $cc_mark_result == "success" } {
		    db_dml transaction_success_update "update ec_financial_transactions set marked_date=sysdate where transaction_id=:transaction_id"
		}
	    }
	}
    }
}

# send the "Order Shipped" email iff it was a shippable order

if { $shippable_p } {
    ec_email_order_shipped $shipment_id
}

ad_returnredirect "fulfillment"
