# /tcl/ecommerce-credit.tcl
ad_library {

    Procedures related to credit card transactions for the ecommerce module

    @author Eve Andersson (eveander@arsdigita.com)
    @date 1 April 1999
    @cvs-id ecommerce-credit.tcl,v 3.3.2.3 2000/08/17 17:37:13 seb Exp
    @author ported by Jerry Asher (jerry@theashergroup.com)

}

# If transaction_id is null, it tries to do an auth for the entire
# order; otherwise it tries to do an auth for the tranaction_amount.
# You can leave order_id blank if you're using a transaction_id
# (useful for gift certificates).
proc ec_creditcard_authorization { order_id {transaction_id ""} } {

    # Gets info it needs from database.
    # Calls ec_talk_to_cybercash to authorize card (which in turn writes a line
    # to the ec_cybercash_log table).
    # Outputs one of the following strings, corresponding to the level of 
    # authorization:
    # (a) failed_authorization
    # (b) authorized_plus_avs
    # (c) authorized_minus_avs
    # (d) no_recommendation
    # (e) invalid_input
    # Case (d) occurs when CyberCash gives an error that is unrelated to 
    # the credit card used, such as timeout or failure-q-or-cancel.
    # Case (e) occurs when there are no orders with the given order_id
    # or with no billing_zip_code.  This case shouldn't
    # happen, since this proc is called from a tcl script with known
    # order_id, and billing_zip_code shouldn't be null.

    if { [empty_string_p $transaction_id] } {

	db_1row order_data_select {
	    select ec_order_cost(:order_id) as total_amount,
	           creditcard_id,
	           decode(sign(sysdate - confirmed_date - .95), -1, 1, 0) as youth
	      from ec_orders
	     where order_id = :order_id
	}

    } else {

	db_1row transaction_data_select {
	    select transaction_amount as total_amount,
	           creditcard_id,
	           decode(sign(sysdate-inserted_date-.95),-1,1,0) as youth
	    from ec_financial_transactions
	    where transaction_id = :transaction_id
	}

    }

    # Check immediately if the total amount is 0,
    # and, if so, just authorize it.
    if {$total_amount == 0} {
	return "authorized_plus_avs"
    }

    set currency [util_memoize {ad_parameter -package_id [ec_id] Currency ecommerce} [ec_cache_refresh]]

    # The above decode, "youth", gives a 1 is the order is younger than 95% of 
    # a day old and a 0 otherwise.  It is used to determine whether the
    # error message "Invalid Credit Card Number" should be believed.
    # Sometimes CyberCash gives the message "Invalid Credit Card Number"
    # to cover up its own incompetency.  But if it gives this message
    # repeatedly throughout the day, then we'll decide to believe it
    # because CyberCash has never been down for more than a few hours
    # at a time in my (Eve's) experience.  I chose 95% of a day instead
    # of a whole day because, if we're going to fail the order anyway, it 
    # should be done before the ecommerce administrator is notified that we couldn't
    # determine whether the order was authorizable (which occurs after
    # 1 day of trying).

    if {
	![db_0or1row creditcard_data_select {
	    select creditcard_number, creditcard_expire,
	           billing_zip_code
	      from ec_creditcards
	     where creditcard_id = :creditcard_id
	}]
    } {

	set level "invalid_input"

    } else {
	
	if { [empty_string_p $transaction_id] } {
	    set transaction_id [db_string latest_transaction_select {
		select max(transaction_id) from ec_financial_transactions where order_id = :order_id
	    }]
	}

	set cc_args [ns_set new]

	ns_set put $cc_args "amount" "$currency $total_amount"
	ns_set put $cc_args "card-number" "$creditcard_number"
	ns_set put $cc_args "card-exp" "$creditcard_expire"
	ns_set put $cc_args "card-zip" "$billing_zip_code"
	ns_set put $cc_args "order-id" "$transaction_id"
	
	set ttcc_output [ec_talk_to_cybercash "mauthonly" $cc_args]
	
	# We're interested in the txn_status, errmsg (if any) and avs_code
	set txn_status [ns_set get $ttcc_output "txn_status"]
	set errmsg [ns_set get $ttcc_output "errmsg"]
	set avs_code [ns_set get $ttcc_output "avs_code"]
	
	# If we get a txn_status of failure-q-or-cancel, it means there was a communications
	# failure and we can retry it (right away).
	# Actually, I might as well let ec_sweep_for_cybercash_zombies take care of it.
	
	if { $txn_status == "failure-bad-money" } {
	    # failed by the financial institution
	    set level "failed_authorization"
	} elseif { $txn_status == "failure-q-or-cancel" || $txn_status == "failure-swversion" } {
	    # failed because of a communications or software problem
	    set level "no_recommendation"
	} elseif { $txn_status == "success" || $txn_status == "success-duplicate" } {
	    # succeeded; use ec_avs_acceptable_p to determine plus_avs or minus_avs

	    if { [ ec_avs_acceptable_p $avs_code ] == 1 } {
		set level "authorized_plus_avs"
	    } else {
		set level "authorized_minus_avs"
	    }
	} elseif { $txn_status == "failure-hard" } {
	    if { [regexp {fails LUHN} $errmsg] } {
		# they must have mistyped credit card number
		set level "failed_authorization"
	    } elseif { [regexp {not configured to accept the card type used} $errmsg] } {
		# they've used an invalid credit card type
		set level "failed_authorization"
	    } elseif { [regexp {Financial Institution} $errmsg] } {
		# authorization declined by financial institution
		set level "failed_authorization"
	    } elseif { [regexp {contains illegal characters} $errmsg] } {
		# they mistyped their credit card number (we've taken out
		# the spaces and dashes, so they've put in some other
		# illegal character)
		set level "failed_authorization"
	    } elseif { [regexp {Invalid credit card number} $errmsg] } {
		# This is the error message CyberCash uses to cover up
		# its own incompetecy, as explained above.
		if { $youth == 1 } {
		    set level "no_recommendation"
		} else {
		    set level "failed_authorization"
		}
	    } elseif { [regexp {DataBase error} $errmsg] } {
		# CyberCash database problem
		set level "no_recommendation"
	    } elseif { [regexp {Could not connect to Merchant Payment Server} $errmsg] } {
		# CyberCash communications problem
		set level "no_recommendation"
	    } elseif { [regexp {failed to respond} $errmsg] } {
		# CyberCash communications problem
		set level "no_recommendation"
	    } elseif { [regexp {Error while reading message} $errmsg] } {
		# yet another CyberCash communications problem
		set level "no_recommendation"
	    } elseif { [regexp -nocase {expiration} $errmsg] } {
		# problem with the expiration date (prob. it has passed)
		set level "failed_authorization"
	    } else {
		# problem is one that Eve is not familiar with, so the customer is
		# given the benefit of the doubt.
		set level "no_recommendation"
	    }
	} else {
	    # The above status codes (success, success-duplicate, failure-hard,
	    # failure-q-or-cancel, failure-swversion and failure-bad-money) are
	    # the only ones returned according to the CyberCash development guide.
	    # If there's a different status code, it will have to be handled
	    # specially.
	    set level "no_recommendation"
	}
    }
    return $level
}

proc ec_creditcard_marking { transaction_id } {

    ns_log Notice "begin ec_creditcard_marking on transaction $transaction_id"

    # Gets info it needs from database.
    # Calls ec_talk_to_cybercash to mark transaction for batching (which in turn 
    # writes a line to the ec_cybercash_log table).
    # Outputs one of the following strings corresponding to whether or
    # not the marking was successful:
    # (a) success
    # (b) failure
    # (c) invalid_input
    # (d) unknown
    # In most instances, case (a) will occur because there are few
    # chances for failure; CyberCash is not contacting the processor,
    # and the card number has already been determined to be valid.
    # Case (b) may occur, for instance, if there is a communications 
    # failure with CyberCash.  Also, CyberCash will fail a postauth
    # if the transaction has already been marked or if the postauth amount
    # is higher than the original authorized amount.  Of course, the 
    # .tcl script that calls this proc shouldn't be trying to mark an 
    # transaction that's already been marked and, because the transaction
    # amount is stored in the database , there should be no
    # discrepancy in the auth amount and the postauth amount.
    # Case (c) occurs if there is no transaction with the given transaction_id.
    # If case (c) occurs, then there is probably an error in 
    # the .tcl script that called this proc.
    # Case (d) is not expected to occur.  This proc outputs "unknown"
    # if cases (a), (b) and (c) do not apply.

    set transaction_amount [db_string transaction_amount_select {
	select transaction_amount from ec_financial_transactions where transaction_id = :transaction_id
    } -default ""]

    if { [empty_string_p $transaction_amount] } {
	ns_log Notice "Eve debug 1"
	set mark_status "invalid_input"
    } else {	
	if {$transaction_amount == 0 } {
	ns_log Notice "Eve debug 2"
	    return "success"
	} else {
	    ns_log Notice "Eve debug 3"
	    set cc_args [ns_set new]

	    set currency [util_memoize {ad_parameter -package_id [ec_id] Currency ecommerce} [ec_cache_refresh]]

	    ns_set put $cc_args "amount" "$currency $transaction_amount"
	    ns_set put $cc_args "order-id" "$transaction_id"
	    
	    set ttcc_output [ec_talk_to_cybercash "postauth" $cc_args] 
	    
	    ns_log Notice "Eve debug 4"
	    # We're only (for the purposes of this proc) interested in
	    # the txn_status (if you want to see error messages, query
	    # the cybercash_log).
	    
	    set txn_status [ns_set get $ttcc_output "txn_status"]
	    
	    if { [regexp {success} $txn_status] } {
		set mark_status "success"
	    } elseif { [regexp {failure} $txn_status] } {
		set mark_status "failure"
	    } else {
		set mark_status "unknown"
	    }
	}
    }
    ns_log Notice "end ec_creditcard_marking on transaction $transaction_id"
    return $mark_status
}

proc ec_creditcard_return { transaction_id } {
    # Calls ec_talk_to_cybercash to mark order for return (which in turn 
    # writes a line to the ec_cybercash_log table).
    # Outputs one of the following strings corresponding to whether or
    # not the marking was successful:
    # (a) success
    # (b) failure
    # (c) invalid_input
    # (d) unknown
    # In most instances, case (a) will occur because there are few
    # chances for failure; CyberCash is not contacting the processor,
    # and the card number has already been determined to be valid.
    # Case (b) may occur, for instance, if there is a communications 
    # failure with CyberCash.  Also, CyberCash will fail a return
    # if the order has already been marked for return, if the return
    # has been settled, or if the return 
    # amount is higher than the settled amount.  Of course, the 
    # .tcl script that calls this proc shouldn't be trying to mark an 
    # transaction for return that's has already had a return marked or settled.
    # Case (c) occurs if there is no transaction with the given transaction_id, or
    # if the transaction_amount column is empty for that transaction
    # If case (c) occurs, then there is probably an error in 
    # the .tcl script that called this proc.
    # Case (d) is not expected to occur.  This proc outputs "unknown"
    # if cases (a), (b) and (c) do not apply.

    if {
	![db_0or1row transaction_info_select {
	    select t.transaction_amount,
	           c.creditcard_number,
	           c.creditcard_expire,
	           c.billing_zip_code
	      from ec_financial_transactions t,
	           ec_creditcards c
	     where t.transaction_id = :transaction_id
	       and c.creditcard_id = t.creditcard_id
	}]
    } {

	set return_status "invalid_input"

    } else {

    
	if { $transaction_amount == 0 } {
	    return "success"
	} else {

	    set cc_args [ns_set new]
	    
	    ns_set put $cc_args "amount" "[util_memoize {ad_parameter -package_id [ec_id] Currency ecommerce} [ec_cache_refresh]] $transaction_amount"
	    ns_set put $cc_args "order-id" "$transaction_id"
	    ns_set put $cc_args "card-number" "$creditcard_number"
	    ns_set put $cc_args "card-exp" "$creditcard_expire"
	    ns_set put $cc_args "card-zip" "$billing_zip_code"

	    set ttcc_output [ec_talk_to_cybercash "return" $cc_args] 
	    
	    # We're only (for the purposes of this proc) interested in
	    # the txn_status (if you want to see error messages, query
	    # the ec_cybercash_log).
	    
	    set txn_status [ns_set get $ttcc_output "txn_status"]
	    
	    if { [regexp {success} $txn_status] } {
		set return_status "success"
	    } elseif { [regexp {failure} $txn_status] } {
		set return_status "failure"
	    } else {
		set return_status "unknown"
	    }

	}
	return $return_status
    }
}

proc_doc ec_get_from_quasi_form {quasi_form key} "CyberCash sometimes gives us a value back that is itself key/value pairs but in standard HTTP request form (e.g., \"foo=5&bar=7\").  We couldn't find an AOLserver API call that pulls this apart (though obviously the code is there somewhere, presumably in C)." {
    if [regexp "$key=(\[^&\]*)" $quasi_form match the_value] {
	return $the_value
    } else {
	return ""
    }
}

proc_doc ec_talk_to_cybercash { txn_attempted_type cc_args } "This procedure talks to CyberCash to do whatever transaction is specified, adds a row to the ec_cybercash_log table, and returns all of CyberCash's output in an ns_set" {

    # Possible values of txn_attempted_type are listed below and
    # in the data model (in the ec_cybercash_log table).
    # cc_args should be an ns_set containing the key/value
    # pairs to be sent to CyberCash, as follows:
    #
    # txn_attempted_type    mandatory keys in cc_args
    # ------------------    -------------------------
    # mauthonly             amount (containing currency & price), 
    #                         order-id, card-number, card-exp, 
    #                         [card-zip, card-country and
    #                         card-name are optional]
    # postauth              amount (currency & price), order-id
    # return                amount (currency & price), order-id
    # void                  txn-type (value should be marked or 
    #                         markret), order-id
    # retry                 order-id, txn-type (value in auth,
    #                         postauth, return, voidmark, voidreturn)
    # query                 order-id, txn-type (value in auth, marked,
    #                         settled, markret, setlret, voidmark,
    #                         voidreturn)
    #
    # (September 5, 1999, eveander) When performing queries, the
    # following sentence is no longer true as of sometime in 1999:
    # "Note that this proc assumes we're querying by order-id and
    # txn-type which means that only 0 or 1 relevant row will be
    # returned."  I'm still going to assume that we're querying by
    # order-id and txn-type, but due to CyberCash's unannounced and
    # undocumented changes in the results of the API call "query",
    # any number of rows may be returned and they may or may not
    # contain information about the specified transaction type. So
    # I've had to fix ec_talk_to_cybercash to make it dig through all
    # the irrelevant rows returned when querying. The output of
    # ec_talk_to_cybercash will remain the same, so you don't need
    # to change any code that uses this procedure.
    #
    # If you want to query by, say, order-id and txn-status, do not use
    # this proc.  You'll need to specially handle all the rows of data
    # returned by CyberCash.
    #
    # This proc returns the info that CyberCash returns, except that
    # variables are slightly renamed to stick with legal tcl variable
    # names and our own naming conventions.

    set currency [util_memoize {ad_parameter -package_id [ec_id] Currency ecommerce} [ec_cache_refresh]]

    if { [ns_set get $cc_args "amount"] != "" } {
	# This is to take care of cases where the tax table has output an
	# amount that contains a fraction of a cent, which CyberCash
	# dislikes
	set smart_amount [ns_set get $cc_args "amount"]
	regsub -all {[^0-9\.]} $smart_amount "" smart_amount
	
	ns_set update $cc_args "amount" "$currency [format "%0.2f" $smart_amount]"
    }

    if { ![ec_use_cybercash_p] } {
	# ignore cybercash and assume success on any operation
	# This will hold what this proc (ec_talk_to_cybercash) outputs
	set ttcc_output [ns_set new]

	ns_set put $ttcc_output "txn_status" "success"
	ns_set put $ttcc_output "errloc" ""
	ns_set put $ttcc_output "errmsg" ""
	ns_set put $ttcc_output "merch_txn" ""
	ns_set put $ttcc_output "cust_txn" ""
	ns_set put $ttcc_output "aux_msg" ""
	ns_set put $ttcc_output "auth_code" ""
	ns_set put $ttcc_output "action_code" ""
	ns_set put $ttcc_output "avs_code" "A"
	ns_set put $ttcc_output "ref_code" ""

	# Figure out what to stick into txn_type
	if { $txn_attempted_type == "mauthonly" } {
	    set txn_type "auth"
	} elseif { $txn_attempted_type == "postauth" } {
	    set txn_type "postauth"
	} elseif { $txn_attempted_type == "return" } {
	    set txn_type "markret"
	} elseif { $txn_attempted_type == "void" && [ns_set get $cc_args "txn-type"] == "marked" } {
	    set txn_type "voidmark"
	} elseif { $txn_attempted_type == "void" && [ns_set get $cc_args "txn-type"] == "markret" } {
	    set txn_type "voidreturn"
	} elseif { $txn_attempted_type == "retry" && [ns_set get $cc_args "txn-type"] == "auth" } {
	    set txn_type "auth"
	} elseif { $txn_attempted_type == "retry" && [ns_set get $cc_args "txn-type"] == "postauth" } {
	    set txn_type "marked"
	} elseif { $txn_attempted_type == "retry" && [ns_set get $cc_args "txn-type"] == "return" } {
	    set txn_type "markret"
	} elseif { $txn_attempted_type == "retry" && [ns_set get $cc_args "txn-type"] == "voidmark" } {
	    set txn_type "voidmark"
	} elseif { $txn_attempted_type == "retry" && [ns_set get $cc_args "txn-type"] == "voidreturn" } {
	    set txn_type "voidreturn"
	} else {
	    set txn_type "unknown"
	}

	ns_set put $ttcc_output "txn_type" $txn_type
	return $ttcc_output
    }

    # This will hold what CyberCash outputs
    set cc_output [ns_set new]

    # This will hold what this proc (ec_talk_to_cybercash) outputs
    set ttcc_output [ns_set new]

    cc_send_to_server_21 "$txn_attempted_type" $cc_args $cc_output

    # For non-queries, just grab the info in $cc_output and put
    # it into $ttcc_output with the keys renamed (and also stick in
    # txn_type, which isn't returned in non-queries; we want to
    # insert the txn_type that *would* have been returned if it had
    # been a query, for consistency).  Note that some (many) of 
    # the values will be the empty string because no single 
    # transaction returns values for every key.

    if { $txn_attempted_type != "query" } {
	ns_set put $ttcc_output "txn_status" "[ns_set get $cc_output "MStatus"]"
	ns_set put $ttcc_output "errloc" "[ns_set get $cc_output "MErrLoc"]"
	ns_set put $ttcc_output "errmsg" "[ns_set get $cc_output "MErrMsg"]"
	ns_set put $ttcc_output "merch_txn" "[ns_set get $cc_output "merch-txn"]"
	ns_set put $ttcc_output "cust_txn" "[ns_set get $cc_output "cust-txn"]"
	ns_set put $ttcc_output "aux_msg" "[ns_set get $cc_output "aux-msg"]"
	ns_set put $ttcc_output "auth_code" "[ns_set get $cc_output "auth-code"]"
	ns_set put $ttcc_output "action_code" "[ns_set get $cc_output "action-code"]"
	ns_set put $ttcc_output "avs_code" "[ns_set get $cc_output "avs-code"]"
	ns_set put $ttcc_output "ref_code" "[ns_set get $cc_output "ref-code"]"

	# Figure out what to stick into txn_type
	if { $txn_attempted_type == "mauthonly" } {
	    set txn_type "auth"
	} elseif { $txn_attempted_type == "postauth" } {
	    set txn_type "postauth"
	} elseif { $txn_attempted_type == "return" } {
	    set txn_type "markret"
	} elseif { $txn_attempted_type == "void" && [ns_set get $cc_args "txn-type"] == "marked" } {
	    set txn_type "voidmark"
	} elseif { $txn_attempted_type == "void" && [ns_set get $cc_args "txn-type"] == "markret" } {
	    set txn_type "voidreturn"
	} elseif { $txn_attempted_type == "retry" && [ns_set get $cc_args "txn-type"] == "auth" } {
	    set txn_type "auth"
	} elseif { $txn_attempted_type == "retry" && [ns_set get $cc_args "txn-type"] == "postauth" } {
	    set txn_type "marked"
	} elseif { $txn_attempted_type == "retry" && [ns_set get $cc_args "txn-type"] == "return" } {
	    set txn_type "markret"
	} elseif { $txn_attempted_type == "retry" && [ns_set get $cc_args "txn-type"] == "voidmark" } {
	    set txn_type "voidmark"
	} elseif { $txn_attempted_type == "retry" && [ns_set get $cc_args "txn-type"] == "voidreturn" } {
	    set txn_type "voidreturn"
	} else {
	    set txn_type "unknown"
	}

	ns_set put $ttcc_output "txn_type" $txn_type
    
    } elseif { $txn_attempted_type == "query" } {

	set cc_output_size [ns_set size $cc_output]

	set relevant_cc_data ""
	
	for {set i 0} {$i < $cc_output_size} {incr i} {
	    set one_row_of_cc_data [ns_set value $cc_output $i]
	    set cc_txn_type [ec_get_from_quasi_form $one_row_of_cc_data txn-type]
	    if { $cc_txn_type == [ns_set get $cc_args "txn-type"] } {
		set relevant_cc_data $one_row_of_cc_data
	    }
	}

	if {![empty_string_p $relevant_cc_data]} {
	    # If it's a query, we have to do some regexping because 
	    # ns_sets of non-ns_set key/value pairs are returned.
	    # It's the 2nd value of $cc_output that's of interest
	    # (no longer true as of September 5, 1999; see comment
	    # at top of this procedure; so we've set relevant_cc_data
	    # above).
	    # Note that the cc_time returned isn't a date as far
	    # as Oracle is concerned (it's a string, so you'll have
	    # to do a to_date('$cc_time','YYYYMMDDHH24MISS') when inserting).
	    	    
	    ns_set put $ttcc_output "txn_type" [ec_get_from_quasi_form $relevant_cc_data txn-type]
	    ns_set put $ttcc_output "cust_txn" [ec_get_from_quasi_form $relevant_cc_data cust-txn]
	    ns_set put $ttcc_output "merch_txn" [ec_get_from_quasi_form $relevant_cc_data merch-txn]
	    ns_set put $ttcc_output "origin" [ec_get_from_quasi_form $relevant_cc_data origin]
	    ns_set put $ttcc_output "txn_status" [ec_get_from_quasi_form $relevant_cc_data txn-status]
	    # we have to handle date specially so as not to confuse Oracle with
	    # subsecond precision
	    regexp {time=([^.]*)\.} $relevant_cc_data garbage ugly_date
	    if { ![info exists ugly_date] } {
		set ugly_date ""
	    }
	    ns_set put $ttcc_output "cc_time" $ugly_date
	    ns_set put $ttcc_output "auth_code" [ec_get_from_quasi_form $relevant_cc_data auth-code]
	    ns_set put $ttcc_output "action_code" [ec_get_from_quasi_form $relevant_cc_data action-code]
	    ns_set put $ttcc_output "avs_code" [ec_get_from_quasi_form $relevant_cc_data avs-code]
	    ns_set put $ttcc_output "ref_code" [ec_get_from_quasi_form $relevant_cc_data ref-code]
	    ns_set put $ttcc_output "batch_id" [ec_get_from_quasi_form $relevant_cc_data batch-id]
	    set long_amount [ec_get_from_quasi_form $relevant_cc_data amount]
	    regsub -all {[^0-9\.]} $long_amount "" numeric_amount
	    # regexp {^[util_memoize {ad_parameter -package_id [ec_id] Currency ecommerce} [ec_cache_refresh]] (.*)} $long_amount garbage numeric_amount
	    if { [info exists numeric_amount] } {
		ns_set put $ttcc_output "amount" $numeric_amount	
	    } else {
		ns_set put $ttcc_output "amount" ""	
	    }
	}

    }
	
    # Add a row to cybercash_log

    set bind_vars [ad_tcl_list_list_to_ns_set [list \
						   [list transaction_id [ns_set get $cc_args "order-id"]] \
						   [list txn_attempted_type $txn_attempted_type] \
						   [list txn_type [ns_set get $ttcc_output "txn_type"]] \
						   [list cc_time [ns_set get $ttcc_output "cc_time"]] \
						   [list merch_txn [ns_set get $ttcc_output "merch_txn"]] \
						   [list cust_txn [ns_set get $ttcc_output "cust_txn"]] \
						   [list origin [ns_set get $ttcc_output "origin"]] \
						   [list txn_status [ns_set get $ttcc_output "txn_status"]] \
						   [list errloc	[ns_set get $ttcc_output "errloc"]] \
						   [list errmsg	[ns_set get $ttcc_output "errmsg"]] \
						   [list aux_msg [ns_set get $ttcc_output "aux_msg"]] \
						   [list auth_code [ns_set get $ttcc_output "auth_code"]] \
						   [list action_code [ns_set get $ttcc_output "action_code"]] \
						   [list avs_code [ns_set get $ttcc_output "avs_code"]] \
						   [list ref_code [ns_set get $ttcc_output "ref_code"]] \
						   [list batch_id [ns_set get $ttcc_output "batch_id"]] \
						   [list amount [ns_set get $ttcc_output "amount"]]]]

    db_dml cybercash_log_insert "
	insert into ec_cybercash_log ([join [ad_ns_set_keys -exclude "cc_time" $bind_vars] ", "], cc_time, txn_attempted_time)
        values ([join [ad_ns_set_keys -exclude "cc_time" -colon $bind_vars] ", "], to_date(:cc_time, 'YYYYMMDDHH24MISS'), sysdate)
    " -bind $bind_vars

    # Finally, return the ns_set
    return $ttcc_output
}

proc_doc ec_avs_acceptable_p {avs_code_from_cybercash} "Returns 1 if the AVS code is acceptable (implying that the consumer address sufficiently matches the creditor's records), or 0 otherwise" {
    set acceptable_codes [list A W X Y Z]
    if { [lsearch $acceptable_codes $avs_code_from_cybercash] != -1 } {
	# code was valid
	return 1
    } else {
	return 0
    }
}

proc_doc ec_date_to_cybercash_date_for_query { the_date n_hours_to_add } "turns date in the format YYYY-MM-DD HH24:MI:SS into CyberCash's format yyyymmddhhmmss with n_hours_to_add hours added because CyberCash uses GMT" {
    return [db_string cybercash_date_create {
	select to_char(:n_hours_to_add / 24 + to_date(:the_date, 'YYYY-MM-DD HH24:MI:SS'), 'YYYYMMDDHH24MISS') from dual
    }]
}

# If you're going to accept cards other than MasterCard, Visa, or
# American Express, you'll have to modify this proc to recognize
# them.  It should be easy; just look at the proc ec_creditcard_validation
# (below) to see how different card numbers are formed.
# This script does some basic checks on the credit card and
# returns a list containing exception_count, exception_text.
# The creditcard_number shouldn't contain any special characters;
# numbers only.
# The check to see whether the creditcard_number or creditcard_type
# is the empty string should be done separately.
# m=mastercard, v=visa, a=american express

# ec_check_creditcard_type_number_match
proc ec_creditcard_precheck { creditcard_number creditcard_type } {

    set exception_count 0
    set exception_text ""

    if {[string index $creditcard_number 0] == 5} {
	if {[info exists creditcard_type] && ![empty_string_p $creditcard_type] && [string compare $creditcard_type "m"] != 0 } {
	    incr exception_count
	    append exception_text "<li> Either your credit card type or your credit card number is incorrect (they don't match)."
	}
	if { [string length $creditcard_number] != 16 } {
	    incr exception_count
	    append exception_text "<li> Your credit card number doesn't have the right number of digits."
	}
    } elseif {[string index $creditcard_number 0] == 4} {
	if {[info exists creditcard_type] && ![empty_string_p $creditcard_type] && [string compare $creditcard_type "v"] != 0 } {
	    incr exception_count
	    append exception_text "<li> Either your credit card type or your credit card number is incorrect (they don't match)."
	}
	if { [string length $creditcard_number] != 16 } {
	    incr exception_count
	    append exception_text "<li> Your credit card number doesn't have the right number of digits."
	}
    } elseif {[string index $creditcard_number 0] == 3} {
	if {[info exists creditcard_type] && ![empty_string_p $creditcard_type] && [string compare $creditcard_type "a"] != 0 } {
	    incr exception_count
	    append exception_text "<li> Either your credit card type or your credit card number is incorrect (they don't match)."
	}
	if { [string length $creditcard_number] != 15 } {
	    incr exception_count
	    append exception_text "<li> Your credit card number doesn't have the right number of digits."
	}
    } else {
	if {[info exists creditcard_type] && ![empty_string_p $creditcard_type]} {
	    incr exception_count
	    append exception_text "<li> Sorry, the credit card number you input is not a Mastercard, Visa, or American Express card number."
	}
    }

    # only if there haven't been any problems so far should we do LUHN-10 error
    # checking which the customer is less likely to understand
    if { $exception_count == 0 } {
	set vallas_creditcard_type [ec_decode [ec_creditcard_validation $creditcard_number] "MasterCard" "m" "VISA" "v" "American Express" "a" "other"]
	if { $vallas_creditcard_type != $creditcard_type } {
	    incr exception_count
	    append exception_text "<li>There's something wrong with the credit card number you entered.  Please check whether you have any transposed digits, missing digits, or similar errors."
	}
    }
    return [list $exception_count $exception_text]
}

# This procedure, originally called valCC, by Horace Vallas was
# found at http://www.hav.com/valCC/nph-src.htm?valCC.nws
# (with an HTML demo at https://enterprise.neosoft.com/secureforms/hav/default.htm).
# It has been left unchanged except for the name.  -- eveander@arsdigita.com
 
# H.V.'s comments:

# This is a demo NeoWebScript by Horace Vallas - 3-7-97 according to some info
#  I found on the web that was attibuted to ICVERIFY by Hal Stiles hstiles@beachnet.com
# http://www.beachnet.com/~hstiles/cardtype.html
#
# You are welcome to use it; however, I make no warranty whatsoever about the
# accuracy or usefullness of this script.  By using this script, you are agreeing that
# I am not responsible for any damage, of any kind whatsoever, to you or to any of
#  your customers, clients, partners, friends, relatives, children born or unborne,
# pets, invisible friends, etc. etc. etc.
#===============================================================

# The valCC proc can be used to validate a credit card number as
# being legally formed.
#
#  input is the entered card number
# return is the type of card (if validated)
#                 or  "- unknown-" if it is an unknown or invalid number
#
#  The validation applied (last known date  3/96)  is the so called
#  LUHN Formula (Mod 10) for Validation of Primary Account Number
#  Validation criteria are:
#
#      1. number prefix
#      2. number of digits
#      3. mod10  (for all but enRoute which uses only 1 & 2)
#
# ... according to the following list of criteria requirements:
#
#    Card Type		Prefix			Length	Check-Digit Algoritm
#
#       MC		51 - 55			  16	    mod 10
#
#       VISA		4			13, 16	    mod 10
#
#       AMX		34, 37			  15	    mod 10
#
#       Diners Club /	300 - 305, 36, 38	  14	    mod 10
#       Carte Blanche
#
#       Discover	6011			  16	    mod 10
#
#       enRoute		2014, 2149		  16	    - any -
#
#       JCB		3			  16	    mod 10
#       JCB		2131, 1800		  15	    mod 10
#

# Original name: valCC
proc ec_creditcard_validation {numIn} {
    regsub -all { } $numIn {} entered_number
    set num [split $entered_number {}]	; # a list form of the number
    set numLen [llength $num]		; # the number of digits in the entered number
    set type "-unknown-"

    # first determine the type of card: MC, VISA, AMX, etc.
    # i.e. test prefix and then number of digits

    switch -glob [string range $entered_number 0 3] {

        "51??" -  "52??" -  "53??" -  "54??" -  "55??" 
                {if {$numLen == 16} {set type "MasterCard"}}
        "4???" 
                {if {$numLen == 13 || $numLen == 16} {set type "VISA"}}
        "34??" -  "37??"
                 {if {$numLen == 15}  {set type "American Express"}}
        "300?" -  "301?" -  "302?" -  "303?" - "304?" - "305?" -  "36??" -   "38??" 
                {if {$numLen == 14} {set type "Diner&#39s Club / Carte Blanche"}}
        "6011" 
                {if {$numLen == 16} {set type "Discover"}}
        "2014" -  "2149" 
                {if {$numLen == 15} {set type "enRoute"}; return $type ; # early exit for enRoute}
        "3???" 
                {if {$numLen == 16} {set type "JCB"}}
        "2131" -  "1800"
                 {if {$numLen == 15} {set type "JCB"}}
        default
                {set type "-unknown-"}
    }
    if {$type == "-unknown-"} {
        return $type}  ; #early exit if we already know it is bad

    # if prefix and number of digits are ok,
    # then apply the mod10 check

    set sum 0                                      ; # initialize the running sum

    # sum every  digit starting with the RIGHT-MOST digit
    # on alternate digits (starting with the NEXT-TO-THE-RIGHT-MOST digit)
    # sum all digits in the result of TWO TIMES the alternate digit 
    # RATHER than the original digit itself

    if {[catch {  ; # CATCH this summing loop in case there are non-digit values in the user supplied string
            for {set i [expr $numLen - 1]} {$i >= 0} {} {
                incr sum [lindex $num $i]
                if {[incr i -1] >= 0} {
                    foreach adigit  [split [expr 2 * [lindex $num $i]] {}] {incr sum $adigit}
                    incr i -1
                }
            }
        }] !=  0} {
        return "-unknown-"
    }

    # emulate a mod 10 (base 10) on the calculated number.
    # if there is any remainder, then the number IS NOT VALID
    # so reset type to -unknown-

   set lsum [split $sum {}]
   if {[lindex $lsum [expr [llength $lsum] - 1]]} {set type "-unknown-"}

    return $type
}
