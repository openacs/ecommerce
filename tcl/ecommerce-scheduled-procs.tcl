# /tcl/ecommerce-scheduled-procs.tcl
ad_library {

  Scheduled procedures for the ecommerce module.
  Other ecommerce procedures can be found in ecommerce-*.tcl

  Procedures:
    ec_calculate_product_purchase_combinations
    ec_sweep_for_cybercash_zombies
    ec_sweep_for_cybercash_zombie_gift_certificates
    ec_send_unsent_new_order_email
    ec_send_unsent_new_gift_certificate_order_email
    ec_send_unsent_gift_certificate_recipient_email
    ec_delayed_credit_denied
    ec_expire_old_carts
    ec_remove_creditcard_data

  financial transaction procedures:
    ec_unauthorized_transactions - to_be_captured_date is over 1/2 hr old and authorized_date is null
    ec_unmarked_transactions - to_be_captured_p is 't' and authorized_date is not null and marked_date is null
    ec_unsettled_transactions - marked_date is non-null and settled_date is null
    ec_unrefunded_transactions - transaction_type is 'refund' and inserted_date is over 1/2 hr old and refunded_date is null
    ec_unrefund_settled_transactions - refunded_date is non-null and refund_settled_date is null

  I'll run this nightly so that calculations of popular product
  combinations don't have to be done each time a product's page is
  accessed. I will actually look at all orders, not just orders which
  have been confirmed, so that there will be more data (so this isn't
  *technically* a calculation of people who bought this product also
  bought these products, because the buying didn't have to take place,
  only the placing into the cart).

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date April 1999
  @cvs-id ecommerce-scheduled-procs.tcl,v 3.6.2.4 2000/08/17 17:37:16 seb Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
}

ad_proc ec_calculate_product_purchase_combinations {} { finds product purchase combinations } {
    # for each product, I want to find other products that are items of
    # orders with the same user id

    db_foreach products_select "select product_id from ec_products" {
	set correlated_product_counter 0
	set insert_cols [list]
	set insert_vals [list]
	set update_items [list]
  
	db_foreach correlated_products_select {
	    select i2.product_id as correlated_product_id,
	           count(*) as n_product_occurrences
	      from ec_items i2
	     where i2.order_id in (select o2.order_id
				     from ec_orders o2
				    where o2.user_id in (select user_id
							   from ec_orders o
							  where o.order_id in (select i.order_id
									         from ec_items i
									        where product_id = :product_id)))
	       and i2.product_id <> :product_id
	     group by i2.product_id
	     order by n_product_occurrences desc
	} {
	    if { $correlated_product_counter >= 5 } {
		break
	    }
	    # I don't know whether it will be an update or insert
	    lappend insert_cols "product_$correlated_product_counter"
	    lappend insert_vals $correlated_product_id
	    lappend update_items "product_$correlated_product_counter = $correlated_product_id"
	    incr correlated_product_counter
	}

	if { [db_string product_purchase_comb_select "select count(*) from ec_product_purchase_comb where product_id=:product_id"] == 0 } {
	    if { [llength $insert_cols] > 0 } {
		db_dml product_purchase_comb_insert "
		    insert into ec_product_purchase_comb
		    (product_id, [join $insert_cols ", "])
		    values
		    (:product_id, [join $insert_vals ", "])
		"
	    }
	} else {
	    if { [llength $update_items] > 0 } {
		db_dml product_purchase_comb_update "
		    update ec_product_purchase_comb
		    set [join $update_items ", "]
		    where product_id=:product_id
		"
	    }
	}
    }
}

ad_proc ec_sweep_for_cybercash_zombies {} "Looks for confirmed orders that aren't either failed or authorized, i.e., where we didn't hear back from CyberCash" {
  # cron job to dig up confirmed but not failed or authorized orders
  # over 15 minutes old ("zombies")
  # These only happen when we go off to CyberCash to authorize an order
  # but either we got no response or the response indicated nothing about
  # whether the card was actually valid.  It also happens if the consumer
  # pushes reload after the order is inserted into the database but
  # before it goes through to CyberCash.
  #
  # OVERALL STRATEGY
  # (1) query CyberCash to see if they have a record of the order
  # (2) if CyberCash has the record and it was successful,
  #     update order_state to authorized_plus/minus_avs
  # (3) if CyberCash doesn't have the order or it was inconclusive,
  #     retry order
  #     (a) if successful, update order_state to authorized_*_avs
  #     (b) if inconclusive, leave in this state
  #     (c) if a definite failure, change order_state failed_authorization
  #         (it will later be moved back to in_basket by ec_delayed_credit_denied)

    
  ns_log Notice "ec_sweep_for_cybercash_zombies starting"

  # Note that the outer loop uses $db2, so use $db within it
  db_foreach confirmed_orders_select {
      select order_id, ec_order_cost(order_id) as total_order_price
      from ec_orders
      where order_state = 'confirmed' 
      and (sysdate - confirmed_date) > 1/96
  } {
      ns_log Notice "ec_sweep_for_cybercash_zombies working on order $order_id"
	
      if { $total_order_price == 0 } {
	  set auth_status_is_now "success"
      } else {
	  set transaction_id [db_string transaction_id_select {
	      select max(transaction_id)
	      from ec_financial_transactions
	      where order_id = :order_id
	  }]
	    
	  # Query CyberCash:
	  set cc_args [ns_set new]
	  ns_set put $cc_args "order-id" "$transaction_id"
	  ns_set put $cc_args "txn-type" "auth"
	    
	  set ttcc_output [ec_talk_to_cybercash "query" $cc_args]
	    
	  set txn_status [ns_set get $ttcc_output "txn_status"]
	    
	  if { [regexp {success} $txn_status] } {
	      set auth_status_is_now "success"
	  } elseif { [empty_string_p $txn_status] || [regexp {failure} $txn_status] } {
	      # Retry the authorization
	      set new_cc_status [ec_creditcard_authorization $order_id]
	      if { $new_cc_status == "authorized_plus_avs" || $new_cc_status == "authorized_minus_avs" } {
		  set auth_status_is_now "success"
	      } elseif { $new_cc_status == "failed_authorization" } {
		  set auth_status_is_now "failure"
	      } else {
		  set auth_status_is_now "lack_of_success"
		  if { $new_cc_status == "invalid_input" } {
		      ns_log Notice "invalid input to ec_creditcard_authorization in ec_sweep_for_cybercash_zombies "
		  }
	      }
	  } elseif { [regexp {pending} $txn_status] } {
	      # We need to retry the auth using the API call "retry"
	      
	      set cc_args_2 [ns_set new]
	      ns_set put $cc_args_2 "order-id" "$transaction_id"
	      ns_set put $cc_args_2 "txn-type" "auth"
	      
	      set ttcc_output_2 [ec_talk_to_cybercash "retry" $cc_args_2]
	      
	      if { [regexp {success} [ns_set get $ttcc_output_2 "txn_status"]] } {
		  set auth_status_is_now "success"
	      } else {
		  set auth_status_is_now "lack_of_success"
		  # This proc won't do anything with it in this case.  It'll
		  # be caught next time around (ec_creditcard_authorization
		  # knows how to interpret the various failure messages).
	      }
	  } else {
	      # weird result, which we don't know what to do with. We should
	      # just leave the order_state alone and let it be subjected to this
	      # proc again in another half-hour, by which time things may have
	      # cleared up.
	      
	      set auth_status_is_now "unknown"

	      set problem_details "Strange CyberCash result when querying about auth: [ns_set get $ttcc_output_2 "txn_status"]"
	      
	      db_dml problems_log_insert {
		  insert into ec_problems_log
		  (problem_id, problem_date, problem_details, order_id)
		  values
		  (ec_problem_id_sequence.nextval, sysdate, :problem_details, :order_id)
	      }
	  }
	  # end of non-free order section
      }
	
      # If the auth_status_is_now is "success" or "failure", then we want to 
      # update the order state.  Otherwise, the order
      # stays in the confirmed state.
      
      if { $auth_status_is_now == "success" } {
	  if { ![ec_use_cybercash_p] } {
	      # ignore cybercash and assume credit card is completely authorized
	      set new_order_state "authorized_plus_avs"
	  } elseif { $total_order_price > 0 } {
	      # get avs code from CyberCash log for most recent row containing this
	      # order_id
	      db_1row avs_code_select {
		  select avs_code 
		    from ec_cybercash_log
		   where transaction_id = :transaction_id 
		     and avs_code != ''
		     and txn_attempted_time = (select MAX(txn_attempted_time)
					         from ec_cybercash_log log2
					        where log2.transaction_id = :transaction_id)
	      }
	      if { [ec_avs_acceptable_p $avs_code] == 1 } {
		  set new_order_state "authorized_plus_avs"
	      } else {
		  set new_order_state "authorized_minus_avs"
	      }
	  } else {
	      set new_order_state "authorized_plus_avs"
	  }
	  # update the order_state
	  ec_update_state_to_authorized $order_id [ec_decode $new_order_state "authorized_plus_avs" "t" "f"]
      } elseif { $auth_status_is_now == "failure" } {
	  # this will get changed to in_basket by the ec_delayed_credit_denied proc
	  set new_order_state "failed_authorization"
	  db_dml order_state_update "update ec_orders set order_state=:new_order_state where order_id=:order_id"
      }
  }

  ns_log Notice "ec_sweep_for_cybercash_zombies finishing"
}

ad_proc ec_sweep_for_cybercash_zombie_gift_certificates {} "Looks for confirmed gift certificates that aren't either failed or authorized, i.e., where we didn't hear back from CyberCash" {
  # cron job to dig up confirmed but not failed or authorized gift certificates
  # over 15 minutes old ("zombies")
  # These only happen when we go off to CyberCash to authorize a transaction
  # but either we got no response or the response indicated nothing about
  # whether the card was actually valid.  It can also happen if the consumer
  # pushes reload after the gift certificate is inserted into the database but
  # before it goes through to CyberCash.
  #
  # This is similar to ec_sweep_for_cybercash_zombies except that inconclusiveness
  # is not tolerated in the case of gift certificates.  If it's inconclusive we
  # fail it and send a note telling them to reorder.
  #
  # OVERALL STRATEGY
  # (1) query CyberCash to see if they have a record of the transaction
  # (2) if CyberCash has the record and it was successful,
  #     update gift_certificate_state to authorized_plus/minus_avs
  # (3) if CyberCash doesn't have the transaction or it was inconclusive,
  #     retry order
  #     (a) if successful, update gift_certificate_state to authorized_*_avs
  #     (c) if inconclusive or failure, change gift_certificate_state failed_authorization

  ns_log Notice "ec_sweep_for_cybercash_zombie_gift_certificates starting"
    
  db_foreach gift_certificate_select {
      select g.gift_certificate_id, t.transaction_id
      from ec_gift_certificates g, ec_financial_transactions t
      where g.gift_certificate_id=t.gift_certificate_id
      and g.gift_certificate_state = 'confirmed' 
      and (sysdate - g.issue_date) > 1/96
  } {
      ns_log Notice "ec_sweep_for_cybercash_zombies working on order $order_id"
	
      # there's a 1-1 correspondence between user-purchased gift certificates and
      # financial transactions
      set transaction_id [db_string transaction_id_select "select transaction_id from ec_financial_transactions where gift_certificate_id=:gift_certificate_id"]
	
      # Query CyberCash:
      set cc_args [ns_set new]
      ns_set put $cc_args "order-id" "$transaction_id"
      ns_set put $cc_args "txn-type" "auth"
	
      set ttcc_output [ec_talk_to_cybercash "query" $cc_args]
	
      set txn_status [ns_set get $ttcc_output "txn_status"]
      set avs_code [ns_set get $ttcc_output "avs_code"]

      if { [empty_string_p $txn_status] } {
	  # no response; inconclusive=failure for gift certificates
	  set cybercash_status "failure"
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

      # Now deal with the cybercash_status:
      # 1. If success, update transaction and gift certificate to authorized, 
      #    and send gift certificate order email
      # 2. If failure, update gift certificate and transaction to failed,
      #    and send gift certificate order failure email
      
      if { $cybercash_status == "success" } {
	  if { [ ec_avs_acceptable_p $avs_code ] == 1 } {
	      set cc_result "authorized_plus_avs"
	  } else {
	      set cc_result "authorized_minus_avs"
	  }
	  # update transaction and gift certificate to authorized
	  # setting to_be_captured_p to 't' will cause ec_unmarked_transactions to come along and mark it for capture
	  db_dml financial_transactions_update {
	      update ec_financial_transactions
	      set authorized_date=sysdate,
	      to_be_captured_p='t'
	      where transaction_id = :transaction_id
	  }

	  db_dml gift_certificate_state_update {
	      update ec_gift_certificates
	         set authorized_date = sysdate,
	             gift_certificate_state = :cc_result
	       where gift_certificate_id = :gift_certificate_id
	  }

	  # send gift certificate order email
	  ec_email_new_gift_certificate_order $gift_certificate_id

      } else {
	  # we probably don't need to do this update of to_be_captured_p
	  # because no cron jobs distinguish between null and 'f' right
	  # now, but it doesn't hurt and it might alleviate someone's
	  # concern when they're looking at ec_financial_transactions and
	  # wondering whether they should be concerned that failed_p is
	  # 't'

	  db_dml financial_transactions_update_1 "update ec_financial_transactions set failed_p='t', to_be_captured_p='f' where transaction_id=:transaction_id"
	  db_dml gift_certificate_state_update_1 "update ec_gift_certificates set gift_certificate_state='failed_authorization' where gift_certificate_id=:gift_certificate_id"

	  # send gift certificate order failure email
	  ec_email_gift_certificate_order_failure $gift_certificate_id
      }
  }

  ns_log Notice "ec_sweep_for_cybercash_zombie_gift_certificates finishing"
}

# this procedure is needed because new order email is only sent after
# the order is authorized and some authorizations occur when the user is
# not on the web site or execution of the thread on the site may
# terminate after the order is authorized but before the email is sent

ad_proc ec_send_unsent_new_order_email {} "Finds authorized orders for which confirmation email has not been sent, sends the email, and records that it has been sent." {
    db_foreach unsent_orders_select {
	select order_id
	from ec_orders o
	where (order_state='authorized_plus_avs' or order_state='authorized_minus_avs')
	and (0=(select count(*) from ec_automatic_email_log log where log.order_id=o.order_id and email_template_id=1))
    } {
	ec_email_new_order $order_id
    }
}

# ec_send_unsent_new_gift_certificate_order_email
ad_proc ec_send_unsent_new_gift_certificate_order_email {} "Finds authorized_plus/minus_avs gift certificates for which confirmation email has not been sent, sends the email, and records that it has been sent." {

    db_foreach unsent_gift_certificate_email {
	select gift_certificate_id
	from ec_gift_certificates g
	where (gift_certificate_state='authorized_plus_avs' or gift_certificate_state='authorized_minus_avs')
	and (0=(select count(*) from ec_automatic_email_log log where log.gift_certificate_id=g.gift_certificate_id and email_template_id=4))
    } {
	ec_email_new_gift_certificate_order $gift_certificate_id
    }
}

# ec_send_unsent_gift_certificate_recipient_email
ad_proc ec_send_unsent_gift_certificate_recipient_email {} "Finds authorized_plus/minus_avs gift certificates for which email has not been sent to the recipient, sends the email, and records that it has been sent." {
    ns_log Notice "ec_send_unsent_gift_certificate_recipient_email starting"

    db_foreach unsent_gift_certificate_select {
	select gift_certificate_id
	from ec_gift_certificates g
	where (gift_certificate_state='authorized_plus_avs' or gift_certificate_state='authorized_minus_avs')
	and (0=(select count(*) from ec_automatic_email_log log where log.gift_certificate_id=g.gift_certificate_id and email_template_id=5))
    } {
	ec_email_gift_certificate_recipient $gift_certificate_id
    }

    ns_log Notice "ec_send_unsent_gift_certificate_recipient_email ending"
}

ad_proc ec_delayed_credit_denied {}  { Sends "Credit Denied" email to consumers whose authorization was initially inconclusive and then failed, and then saves the order for them (so that consumer can go back to site and retry the authorization).
} {
    ns_log Notice "ec_delayed_credit_denied starting"
    set order_id_list [db_list denied_orders_select "select order_id from ec_orders where order_state='failed_authorization'"]

    foreach order_id $order_id_list {
	ns_log Notice "working on order #$order_id"

	# save this shopping cart for the user
	db_dml order_state_update "update ec_orders set order_state='in_basket', saved_p='t' where order_id=:order_id"

	ec_email_delayed_credit_denied $order_id
    }

    ns_log Notice "ec_delayed_credit_denied ending"
}

ad_proc ec_expire_old_carts {} { expires old carts } {
    db_transaction {
      db_dml expired_carts_update "update ec_orders set order_state='expired', expired_date=sysdate where order_state='in_basket' and sysdate-in_basket_date > [ad_parameter -package_id [ec_id] CartDuration ecommerce]"
      db_dml item_state_update "update ec_items set item_state='expired', expired_date=sysdate where item_state='in_basket' and order_id in (select order_id from ec_orders where order_state='expired')"
    }
}

ad_proc ec_remove_creditcard_data {} { remove credit card data } {
    # if SaveCreditCardDataP=0 we should remove the creditcard_number for the cards whose numbers are
    # no longer needed (i.e. all their orders are fulfilled, returned, void, or expired)
    if { [ad_parameter -package_id [ec_id] SaveCreditCardDataP ecommerce] == 0 } {
	db_dml creditcard_update {
	    update ec_creditcards
	    set creditcard_number=null
	    where creditcard_id in (select unique c.creditcard_id
				    from ec_creditcards c, ec_orders o
				    where c.creditcard_id = o.creditcard_id
				    and c.creditcard_number is not null
				    and 0=(select count(*)
					   from ec_orders o2
					   where o2.creditcard_id=c.creditcard_id
					   and o2.order_state not in ('fulfilled','returned','void','expired')))
	}
    }
}

# to_be_captured_date is over 1/2 hr old and authorized_date is null
# this is similar to ec_sweep_for_cybercash_zombies except that in this
# case these are shipments that are unauthorized
ad_proc ec_unauthorized_transactions {} { searches for unauthorized transactions } {
    db_foreach unauthorized_transactions_select {
	select transaction_id, order_id from ec_financial_transactions
	where to_be_captured_p='t'
	and sysdate-to_be_captured_date > 1/48
	and authorized_date is null
	and failed_p='f'
    } {
	ns_log Notice "ec_unauthorized_transactions working on transaction_id $transaction_id"

	# Query CyberCash:
	set cc_args [ns_set new]
	ns_set put $cc_args "order-id" "$transaction_id"
	ns_set put $cc_args "txn-type" "auth"

	set ttcc_output [ec_talk_to_cybercash "query" $cc_args]

	if { [regexp {success} [ns_set get $ttcc_output "txn_status"]] } {
	    set auth_status_is_now "success"
	} elseif { [ns_set get $ttcc_output "txn_status"] == "" || [regexp {failure} [ns_set get $ttcc_output "txn_status"]] } {
	    # Retry the authorization
	    set new_cc_status [ec_creditcard_authorization $order_id $transaction_id]
	    
	    if { $new_cc_status == "authorized_plus_avs" || $new_cc_status == "authorized_minus_avs" } {
		set auth_status_is_now "success"
	    } elseif { $new_cc_status == "failed_authorization" } {
		set auth_status_is_now "failure"
	    } else {
		set auth_status_is_now "lack_of_success"
		if { $new_cc_status == "invalid_input" } {
		    db_dml problems_log_insert {
			insert into ec_problems_log
			(problem_id, problem_date, problem_details, order_id)
			values
			(ec_problem_id_sequence.nextval, sysdate, 'invalid input to ec_creditcard_authorization in ec_unauthorized_transactions', :order_id)
		    }
		}
	    }
	} elseif { [regexp {pending} [ns_set get $ttcc_output "txn_status"]] } {
	    # We need to retry the auth using the API call "retry"
	    set cc_args_2 [ns_set new]
	    ns_set put $cc_args_2 "order-id" "$transaction_id"
	    ns_set put $cc_args_2 "txn-type" "auth"
	    
	    set ttcc_output_2 [ec_talk_to_cybercash "retry" $cc_args_2]
	    
	    if { [regexp {success} [ns_set get $ttcc_output_2 "txn_status"]] } {
		set auth_status_is_now "success"
	    } else {
		set auth_status_is_now "lack_of_success"
		# This proc won't do anything with it in this case.  It'll
		# be caught next time around (ec_creditcard_authorization
		# knows how to interpret the various failure messages).
	    }
	} else {
	    # weird result, which we don't know what to do with.  We should just leave
	    # the order_state alone and let it be subjected to this proc again in
	    # another half-hour, by which time things may have cleared up.
	    set auth_status_is_now "unknown"

	    set problem_details "Strange CyberCash result when querying about auth: [ns_set get $ttcc_output_2 "txn_status"]"

	    db_dml problems_insert {
		insert into ec_problems_log
		(problem_id, problem_date, problem_details, order_id)
		values
		(ec_problem_id_sequence.nextval, sysdate, :problem_details, :order_id)
	    }
	} 
	# done determining auth_status
	
	# If the auth_status_is_now is "success" or "failure", then we want to 
	# update the transaction.  Otherwise, it stays as it is.
	
	if { $auth_status_is_now == "success" } {
	    db_dml transaction_success_update "update ec_financial_transactions set authorized_date=sysdate where transaction_id=:transaction_id"
	} elseif { $auth_status_is_now == "failure" } {
	    db_transaction {
		db_dml transaction_failed_update "update ec_financial_transactions set failed_p='t' where transaction_id=:transaction_id"
		set problem_details "The authorization failed for transaction_id $transaction_id."
		db_dml problems_log_insert {
		    insert into ec_problems_log
		    (problem_id, problem_date, problem_details, order_id)
		    values
		    (ec_problem_id_sequence.nextval, sysdate, :problem_details, :order_id)
		}
	    }
	}
    } 

    ns_log Notice "ec_unauthorized_transactions finishing"
}

#  to_be_captured_p is 't' and authorized_date is not null and marked_date is null
ad_proc ec_unmarked_transactions {} { unmarked transactions } {
    ns_log Notice "ec_unmarked_transactions starting"

    db_foreach unmarked_transactions_select {
	select transaction_id, order_id from ec_financial_transactions
	where to_be_captured_p='t'
	and authorized_date is not null
	and marked_date is null
	and failed_p='f'
    } {
	ns_log Notice "ec_unmarked_transactions working on transaction_id $transaction_id"

	set postauth_success [ec_creditcard_marking $transaction_id]
	
	if { $postauth_success != "success" } {
	    
	    # the error may be because the order was already marked, so check for that
	    set cc_args [ns_set new]
	    ns_set put $cc_args "order-id" "$transaction_id"
	    ns_set put $cc_args "txn-type" "postauth"
	    
	    set ttcc_output [ec_talk_to_cybercash "query" $cc_args]
	    
	    if { [regexp {success} [ns_set get $ttcc_output "txn_status"]] } {
		db_dml financial_transaction_success_update "update ec_financial_transactions set marked_date=sysdate where transaction_id=:transaction_id"
	    } else {
		db_transaction {
		    db_dml financial_transaction_failed_update "update ec_financial_transactions set failed_p='t' where transaction_id=:transaction_id"
		    set problem_details "The marking failed for transaction_id $transaction_id."
		    db_dml problems_log_insert {
			insert into ec_problems_log
			(problem_id, problem_date, problem_details, order_id)
			values
			(ec_problem_id_sequence.nextval, sysdate, :problem_details, :order_id)
		    }
		}
	    }
	} else {
	    # postauth successful
	    db_dml financial_transactions_update "update ec_financial_transactions set marked_date=sysdate where transaction_id=:transaction_id"
	}
    }
    ns_log Notice "ec_unmarked_transactions ending"
}

# marked_date is non-null and settled_date is null
# this should be run late at night because CyberCash settled marked transactions in the early night (before midnight)
# if it isn't settled 2 days after it's marked, failed_p is set to 't' and a row is added to the problems_log
ad_proc ec_unsettled_transactions {} { unsettled transactions } {
    ns_log Notice "ec_unsettled_transactions starting"
 
    db_foreach unsettled_transactions_select {
	select transaction_id, order_id from ec_financial_transactions
	where marked_date is not null
	and settled_date is null
	and failed_p='f'
    } {
	ns_log Notice "ec_unsettled_transactions working on transaction_id $transaction_id"

	# query CyberCash
	set cc_args [ns_set new]
	ns_set put $cc_args "order-id" "$transaction_id"
	ns_set put $cc_args "txn-type" "settled"
	
	set ttcc_output [ec_talk_to_cybercash "query" $cc_args]
	if { [regexp {success} [ns_set get $ttcc_output "txn_status"]] } {
	    db_dml settled_date_update "update ec_financial_transactions set settled_date=sysdate where transaction_id=:transaction_id"
	} else {
	    # see if it's been at least 2 days since the order was marked (otherwise, don't bother
	    # making a note of the failure yet; in my experience, there were a number of times
	    # when it took more than a day for us to find out that an order settled, with the delay
	    # perhaps due to CyberCash's nightly settlement not occurring or due to a communications
	    # failure between us and CyberCash)
	    
	    # to see if a > b, check the sign of (1 - (a/b)); if it's positive, then a<b, if it's 0,
	    # then a=b, and if it's negative, then a>b.  I use this in the following decode to see
	    # whether (sysdate - marked_date) > 2.
	    
	    if { [db_string two_days_since_order_was_marked_p "select decode(sign(1 - ((sysdate-marked_date)/2)), -1, 1, 0) from ec_financial_transactions where transaction_id=:transaction_id"] } {
		db_transaction {
		    db_dml transaction_failed_update "update ec_financial_transactions set failed_p='t' where transaction_id=:transaction_id"
		    set problem_details "The settlement failed for transaction_id $transaction_id even though it has been more than 2 days since the transaction was marked."
		    db_dml problems_log_insert {
			insert into ec_problems_log
			(problem_id, problem_date, problem_details, order_id)
			values
			(ec_problem_id_sequence.nextval, sysdate, :problem_details, :order_id)
		    }
		}
	    }
	}
    }
    ns_log Notice "ec_unsettled_transactions ending"
}

#   transaction_type is 'refund' and inserted_date is over 1/2 hr old and refunded_date is null
ad_proc ec_unrefunded_transactions {} { unrefunded transactions } {
    ns_log Notice "ec_unrefunded_transactions starting"

    db_foreach unrefunded_transactions_select {
	select transaction_id, order_id from ec_financial_transactions
	where transaction_type='refund'
	and sysdate - inserted_date > 1/48
	and refunded_date is null
	and failed_p='f'
    } {
	ns_log Notice "ec_unrefunded_transactions working on transaction_id $transaction_id"
	
	set return_success [ec_creditcard_return $transaction_id]
	
	if { $return_success != "success" } {
	    
	    # the error may be because the order was already marked, so check for that
	    set cc_args [ns_set new]
	    ns_set put $cc_args "order-id" "$transaction_id"
	    ns_set put $cc_args "txn-type" "markret"
	    
	    set ttcc_output [ec_talk_to_cybercash "query" $cc_args]
	    
	    if { [regexp {success} [ns_set get $ttcc_output "txn_status"]] } {
		db_dml financial_transactions_update "update ec_financial_transactions set refunded_date=sysdate where transaction_id=:transaction_id"
	    } else {
		db_transaction {
		    db_dml financial_transaction_failed_update "update ec_financial_transactions set failed_p='t' where transaction_id=:transaction_id"
		    set problem_details "The refund (the marking of it) failed for transaction_id $transaction_id."
		    db_dml problems_log_insert {
			insert into ec_problems_log
			(problem_id, problem_date, problem_details, order_id)
			values
			(ec_problem_id_sequence.nextval, sysdate, :problem_details, :order_id)
		    }
		}
	    }
	} else {
	    # refund successful
	    db_dml financial_transaction_refund_update "update ec_financial_transactions set refunded_date=sysdate where transaction_id=:transaction_id"
	}
    }
    ns_log Notice "ec_unrefunded_transactions ending"
}

# refunded_date is non-null and refund_settled_date is null
# yes, I know the name of this proc is gramatically iffy, but I want to be consistent
ad_proc ec_unrefund_settled_transactions {} { unrefunded settled transactions } {
  ns_log Notice "ec_unrefund_settled_transactions starting"

  db_foreach unrefund_settled_transactions_select "select transaction_id, order_id from ec_financial_transactions
  where refunded_date is not null
  and refund_settled_date is null
  and failed_p='f'" {
    ns_log Notice "ec_unrefund_settled_transactions working on transaction_id $transaction_id"

    # query CyberCash
    set cc_args [ns_set new]
    ns_set put $cc_args "order-id" "$transaction_id"
    ns_set put $cc_args "txn-type" "setlret"

    set ttcc_output [ec_talk_to_cybercash "query" $cc_args]
    if { [regexp {success} [ns_set get $ttcc_output "txn_status"]] } {
      db_dml financial_transaction_refund_settled_update "update ec_financial_transactions set refund_settled_date=sysdate where transaction_id=:transaction_id"
    } else {
      # see if it's been at least 2 days since the order was marked (otherwise, don't bother
      # making a note of the failure yet; in my experience, there were a number of times
      # when it took more than a day for us to find out that a refund settled, with the delay
      # perhaps due to CyberCash's nightly settlement not occurring or due to a communications
      # failure between us and CyberCash)

      # to see if a > b, check the sign of (1 - (a/b)); if it's positive, then a<b, if it's 0,
      # then a=b, and if it's negative, then a>b.  I use this in the following decode to see
      # whether (sysdate - refunded_date) > 2.

      if { [db_string two_days_since_order_was_refunded_p "select decode(sign(1 - ((sysdate-refunded_date)/2)), -1, 1, 0) from ec_financial_transactions where transaction_id=:transaction_id"] } {
	db_transaction {
	  db_dml transaction_failed_update "update ec_financial_transactions set failed_p='t' where transaction_id=:transaction_id"
	  set problem_details "The refund settlement failed for transaction_id $transaction_id even though it has been more than 2 days since the transaction was marked refunded."
	  db_dml problems_log_insert "insert into ec_problems_log
	  (problem_id, problem_date, problem_details, order_id)
	  values
	  (ec_problem_id_sequence.nextval, sysdate, :problem_details, :order_id)
	  "
	}
      }
    }
  }
  ns_log Notice "ec_unrefund_settled_transactions ending"
}

## Schedule these procedures

set ec_procs_scheduled_p 0
set ep [ad_parameter -package_id [ec_id] EnabledP ecommerce 0]

if { !$ec_procs_scheduled_p  && $ep} {
    set ec_procs_scheduled_p 1

    # Scheduled proc scheduling:

    # Nightly
    # pi time + 1 = 4:14am EST = late in U.S., early in Europe
    
    ns_log Notice "scheduling ec_calculate_product_purchase_combinations"
    ns_schedule_daily -thread 4 14 ec_calculate_product_purchase_combinations

    # A few times a day
    # every three hours or so (slightly different intervals so they'll eventually space themselves out)

    set infrequent_base [expr 3 * 60 * 60]

    ns_log Notice "scheduling ec_expire_old_carts"
    ad_schedule_proc -thread t [expr $infrequent_base + 0] ec_expire_old_carts
    
    ns_log Notice "scheduling ec_unauthorized_transactions"
    ad_schedule_proc -thread t [expr $infrequent_base + 50] ec_unauthorized_transactions

    ns_log Notice "scheduling ec_unmarked_transactions"
    ad_schedule_proc -thread t [expr $infrequent_base + 10] ec_unmarked_transactions

    ns_log Notice "scheduling ec_unsettled_transactions"
    ad_schedule_proc -thread t [expr $infrequent_base + 150] ec_unsettled_transactions

    ns_log Notice "scheduling ec_unrefunded_transactions"
    ad_schedule_proc -thread t [expr $infrequent_base + 200] ec_unrefunded_transactions

    ns_log Notice "scheduling ec_unrefund_settled_transactions"
    ad_schedule_proc -thread t [expr $infrequent_base + 250] ec_unrefund_settled_transactions

    # Often
    # every half hour or so

    set frequent_base [expr 60 * 10]

    ns_log Notice "scheduling ec_sweep_for_cybercash_zombies"
    ad_schedule_proc -thread t [expr $frequent_base + 0] ec_sweep_for_cybercash_zombies

    ns_log Notice "scheduling ec_sweep_for_cybercash_zombie_gift_certificates"
    ad_schedule_proc -thread t [expr $frequent_base + 25] ec_sweep_for_cybercash_zombie_gift_certificates

    ns_log Notice "scheduling ec_send_unsent_new_order_email"
    ad_schedule_proc -thread t [expr $frequent_base + 50] ec_send_unsent_new_order_email

    ns_log Notice "scheduling ec_delayed_credit_denied"
    ad_schedule_proc -thread t [expr $frequent_base + 100] ec_delayed_credit_denied

    ns_log Notice "scheduling ec_remove_creditcard_data"
    ad_schedule_proc -thread t [expr $frequent_base + 150] ec_remove_creditcard_data

    ns_log Notice "scheduling ec_send_unsent_new_gift_certificate_order_email"
    ad_schedule_proc -thread t [expr $frequent_base + 200] ec_send_unsent_new_gift_certificate_order_email

    ns_log Notice "scheduling ec_send_unsent_gift_certificate_recipient_email"
    ad_schedule_proc -thread t [expr $frequent_base + 250] ec_send_unsent_gift_certificate_recipient_email
}
