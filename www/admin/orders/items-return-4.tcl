# /www/[ec_url_concat [ec_url] /admin]/orders/items-return-4.tcl
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
    
    @param card_query_p
    @param card_query_password
    @param creditcard_number
    @param creditcard_type
    @param creditcard_expire_1
    @param creditcard_expire_2
    @param billing_zip_code

    @author Eve Andersson (eveander@arsdigita.com)
    @creation-date  July 22, 1999
    @cvs-id items-return-4.tcl,v 3.3.2.9 2000/09/22 01:34:58 kevin Exp
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
    cash_amount_to_refund
    certificate_amount_to_reinstate

    card_query_p:optional
    card_query_password:optional
    creditcard_number:optional
    creditcard_type:optional
    creditcard_expire_1:optional
    creditcard_expire_2:optional
    billing_zip_code:optional

}

ad_require_permission [ad_conn package_id] admin

# the customer service rep must be logged on
set customer_service_rep [ad_get_user_id]

if {$customer_service_rep == 0} {
    set return_url "[ad_conn url]?[export_entire_form_as_url_vars]"
    ad_returnredirect "/register?[export_url_vars return_url]"
    return
}

if { [info exists creditcard_number] } {
    # get rid of spaces and dashes
    regsub -all -- "-" $creditcard_number "" creditcard_number
    regsub -all " " $creditcard_number "" creditcard_number
}

# error checking:
# unless the credit card number is in the database or if the total
# amount to refund is $0.00, card_query_p
# should exist and be "t" or "f".  If it's "t", we need a password
# and no new credit card number.  If it's "f", we need new credit
# card information and no card-query password.

set exception_count 0
set exception_text ""



set user_id [db_string get_user_id "select user_id from ec_orders where order_id=:order_id"]

# make sure they haven't already inserted this refund
if { [db_string get_refund_id_check "select count(*) from ec_refunds where refund_id=:refund_id"] > 0 } {
    ad_return_complaint 1 "<li>This refund has already been inserted into the database; it looks like you are using an old form.  <a href=\"one?[export_url_vars order_id]\">Return to the order.</a>"
    return
}

if { [expr $cash_amount_to_refund] > 0 && [empty_string_p [db_string get_credit_card_id "select creditcard_number from ec_orders o, ec_creditcards c where o.creditcard_id=c.creditcard_id and o.order_id=:order_id"]]} {
    
    # then we need a card query or a new credit card number
    if { ![info exists card_query_p] || [empty_string_p $card_query_p] } {
	incr exception_count
	append exception_text "<li>You must specify whether you want to query CyberCash for the old credit card number or whether you want to use a new credit card."
    } elseif { $card_query_p == "t" } {
	if { [empty_string_p $card_query_password] } {
	    incr exception_count
	    append exception_text "<li>You specified that you want to query CyberCash for the old credit card number, but you didn't type in the card-query password."
	}
	if { ![empty_string_p $creditcard_number] } {
	    incr exception_count
	    append exception_text "<li>You specified that you want to query CyberCash for the old credit card number, but you entered a new credit card number.  Please choose one or the other."
	}
    } else {
	
	# card_query_p is "f"
	if { ![empty_string_p $card_query_password] } {
	    incr exception_count
	    append exception_text "<li>You specified that you want to use a new credit card number, but you entered a card-query password.  Please choose one or the other."
	}
	
	if { ![info exists creditcard_number] || [empty_string_p $creditcard_number] } {
	    # then they haven't selected a previous credit card nor have they entered
	    # new credit card info
	    incr exception_count
	    append exception_text "<li> You forgot to specify which credit card you'd like to use."
	} else {
	    # then they are using a new credit card and we just have to check that they
	    # got it all right
	    
	    if { [regexp {[^0-9]} $creditcard_number] } {
		# I've already removed spaces and dashes, so only numbers should remain
		incr exception_count
		append exception_text "<li>The credit card number contains invalid characters."
	    }
	    
	    if { ![info exists billing_zip_code] || [empty_string_p $billing_zip_code] } {
		incr exception_count
		append exception_text "<li>You forgot to enter the billing zip code."
	    }
	    
	    if { ![info exists creditcard_type] || [empty_string_p $creditcard_type] } {
		incr exception_count
		append exception_text "<li> You forgot to enter the credit card type."
	    }
	    
	    # make sure the credit card type is right & that it has the right number
	    # of digits
	    set additional_count_and_text [ec_check_creditcard_type_number_match $creditcard_number $creditcard_type]
	    
	    set exception_count [expr $exception_count + [lindex $additional_count_and_text 0]]
	    append exception_text [lindex $additional_count_and_text 1]
	    
	    if { ![info exists creditcard_expire_1] || [empty_string_p $creditcard_expire_1] || ![info exists creditcard_expire_2] || [empty_string_p $creditcard_expire_2] } {
		incr exception_count
		append exception_text "<li> Please enter the full credit card expiration date (month and year)"
	    }
	}
    }
}

if { $exception_count > 0 } {
    ad_return_complaint $exception_count $exception_text
    return
}

# done with error checking


set case_a_p 0
set case_b_p 0

if { [expr $cash_amount_to_refund] > 0 } {
    # 1. try to get credit card number (insert it if new)
    
    if { [info exists card_query_p] && $card_query_p == "t" } {
	set creditcard_id [db_string get_creditcard_id "select creditcard_id from ec_orders where order_id=:order_id"]
	
	# find the latest transaction with this card number, preferably one with authorized_date set
	set transaction_to_query [db_string get_transaction_to_query "
	select max(transaction_id)
	from ec_financial_transactions
	where creditcard_id=:creditcard_id
	 and (authorized_date is not null OR 0=(select count(*) from ec_financial_transactions where creditcard_id=:creditcard_id and authorized_date is not null)
	"]
	
	# talk to CyberCash to get the card number
	set cc_args [ns_set new]
	set cc_output [ns_set new]
	ns_set put $cc_args "order-id" $transaction_to_query
	ns_set put $cc_args "passwd" $card_query_password
	
	cc_send_to_server_21 "card-query" $cc_args $cc_output
	
	set creditcard_number [ns_set get $cc_output "card-number"]
	
	
	if { [empty_string_p $creditcard_number] } {
	    ad_return_complaint 1 "<li>The card-query was unsuccessful.  Please try again (check the password) or manually enter a new credit card."
	    return
	} else {
	    set case_a_p 1
	}
    } elseif { [info exists card_query_p] && $card_query_p == "f" } {
	set case_b_p 1
    } else {
	set creditcard_id [db_string get_creditcard_id "select creditcard_id from ec_orders where order_id=:order_id"]
    }
}

# 2. put records into ec_refunds, individual items, the order, and
#    ec_financial_transactions

db_transaction {

    if {$case_a_p} {
	db_dml update_cc_number_incctable "update ec_creditcards set creditcard_number=:creditcard_number where creditcard_id=:creditcard_id"
    }

    if {$case_b_p} {
	# insert a new credit card into ec_creditcards
	set creditcard_id [db_string get_new_creditcard_id "select creditcard_id_sequence.nextval from dual"]
	
	set cc_thing "[string range $creditcard_number [expr [string length $creditcard_number] -4] [expr [string length $creditcard_number] -1]]"
	
	set expires "$creditcard_expire_1/$creditcard_expire_2"
	
	db_dml insert_new_cc "insert into ec_creditcards
	(creditcard_id, user_id, creditcard_number, creditcard_last_four, creditcard_type, creditcard_expire, billing_zip_code)
	values
	(:creditcard_id, :user_id, :creditcard_number, :cc_thing, :creditcard_type,:expires,:billing_zip_code)
	"
    }


    db_dml insert_new_ec_refund "insert into ec_refunds
    (refund_id, order_id, refund_amount, refund_date, refunded_by, refund_reasons)
    values
    (:refund_id, :order_id, :cash_amount_to_refund, sysdate, :customer_service_rep,:reason_for_return)
    "

    foreach item_id $item_id_list {
	# this is annoying (doing these selects before each insert), but that's how it goes because we don't
	# want to refund more tax than was actually paid even if the tax rates changed
	
	set price_bind_variable $price_to_refund($item_id)
	set shipping_bind_variable $shipping_to_refund($item_id)

	db_1row get_tax_charged_on_item "select nvl(price_tax_charged,0) as price_tax_charged, nvl(shipping_tax_charged,0) as shipping_tax_charged from ec_items where item_id=:item_id"
	


	
	set price_tax_to_refund [ec_min $price_tax_charged [db_string get_tax_charged "select ec_tax(:price_bind_variable,0,:order_id) from dual"]]
	
	set shipping_tax_to_refund [ec_min $shipping_tax_charged [db_string get_tax_shipping_to_refund "select ec_tax(0,:shipping_bind_variable,:order_id) from dual"]]
	
	db_dml update_item_return "
	update ec_items set item_state='received_back',
	                    received_back_date=to_date(:received_back_datetime,'YYYY-MM-DD HH12:MI:SSAM'),
                            price_refunded=:price_bind_variable,
                            shipping_refunded=:shipping_bind_variable,
                            price_tax_refunded=:price_tax_to_refund,
                            shipping_tax_refunded=:shipping_tax_to_refund,
                            refund_id=:refund_id
               where item_id=:item_id"
    }
    
    set base_shipping_tax_charged [db_string get_base_shipping_tax "select nvl(shipping_tax_charged,0) from ec_orders where order_id=:order_id"]
    set base_shipping_tax_to_refund [ec_min $base_shipping_tax_charged [db_string get_base_tax_to_refund "select ec_tax(0,:base_shipping_to_refund,:order_id) from dual"]]
    
    db_dml update_ec_order_set_shipping_refunds "update ec_orders set shipping_refunded=:base_shipping_to_refund, shipping_tax_refunded=:base_shipping_tax_to_refund where order_id=:order_id"
    
    if { [expr $cash_amount_to_refund] > 0 } {
	
	# 1999-08-11: added refund_id to the insert
	set transaction_id [db_string get_new_trans_id "select ec_transaction_id_sequence.nextval from dual"]
	db_dml insert_new_financial_trans "insert into ec_financial_transactions
	(transaction_id, order_id, refund_id, creditcard_id, transaction_amount, transaction_type, inserted_date)
	values
	(:transaction_id, :order_id, :refund_id, :creditcard_id, :cash_amount_to_refund, 'refund', sysdate)
	"
    }
    
    # 3. do the gift certificate reinstatements (start with ones that expire furthest in
    # to future)
    
    if { $certificate_amount_to_reinstate > 0 } {
	
	# this will be a list of 2-element lists (gift_certificate_id, original_amount)
	set certs_to_reinstate_list [list]
	set sql "select u.gift_certificate_id, c.amount as original_amount
	from ec_gift_certificate_usage u, ec_gift_certificates c
	where u.gift_certificate_id = c.gift_certificate_id
	and u.order_id = :order_id
	order by expires desc
	gift_certificate_id desc"
	db_foreach get_gift_certs_to_reinstate $sql {
	    
	    lappend certs_to_reinstate_list [list $gift_certificate_id $original_amount]
	}
	
	# the amount used on that order
	set certificate_amount_used [db_string get_gc_amount_used "select ec_order_gift_cert_amount(:order_id) from dual"]
	
	if { $certificate_amount_used < $certificate_amount_to_reinstate } {
	    
	    set errorstring "We were unable to reinstate the customer's gift certificate balance because the amount to be reinstated was larger than the original amount used.  This shouldn't have happened unless there was a programming error or unless the database was incorrectly updated manually.  This transaction was aborted (refund_id $refund_id), i.e. no refund was given to the customer."
	    
	    db_dml insert_too_little_gc "insert into ec_problems_log
	    (problem_id, problem_date, problem_details, order_id)
	    values
	    (ec_problem_id_sequence.nextval, sysdate, :errorstring, :order_id)
	    "
	    ad_return_error "Gift Certificate Error" "We were unable to reinstate the customer's gift certificate balance because the amount to be reinstated was larger than the original amount used.  This shouldn't have happened unless there was a programming error or unless the database was incorrectly updated manually.<p>This transaction has been aborted, i.e. no refund has been given to the customer.  This has been logged in the problems log."
	    return
	} else {
	    # go through and reinstate certificates in order; it's not so bad
	    # to loop through all of them because I don't expect there to be
	    # many
	    
	    set amount_to_reinstate $certificate_amount_to_reinstate
	    foreach cert_and_original_amount $certs_to_reinstate_list {
		if { $amount_to_reinstate > 0 } {
		    set cert [lindex $cert_and_original_amount 0]
		    set original_amount [lindex $cert_and_original_amount 1]
		    set reinstatable_amount [expr $original_amount - [db_string get_gc_amt_left "select gift_certificate_amount_left(:cert) from dual"]]
		    if { $reinstatable_amount > 0 } {
			set iteration_reinstate_amount [ec_min $reinstatable_amount $amount_to_reinstate]
			
			db_dml insert_new_gc_usage_reinstate "insert into ec_gift_certificate_usage
			(gift_certificate_id, order_id, amount_reinstated, reinstated_date)
			values
			(:cert, :order_id, :iteration_reinstate_amount, sysdate)
			"
			
			set amount_to_reinstate [expr $amount_to_reinstate - $iteration_reinstate_amount]
		    }
		}
	    }
	}
    }
}    

# end the transaction before going out to CyberCash to do the refund (if it fails,
# we still have a row in ec_financial_transactions telling us that it tried to do
# the refund, so we will know it needs to be done)



# 4. try to do refund

if { $cash_amount_to_refund > 0} {
    # transaction_id should exist if the above is true
    set refund_status [ec_creditcard_return $transaction_id]
    if { $refund_status == "failure" || $refund_status == "invalid_input" } {

	set errorstring "When trying to refund refund_id $refund_id (transaction $transaction_id) at [ad_conn url], the following result occurred: $refund_status"

	db_dml insert_cc_refund_problem "insert into ec_problems_log
	(problem_id, problem_date, problem_details, order_id)
	values
	(ec_problem_id_sequence.nextval, sysdate, :errorstring, :order_id)
	"
	set results_explanation "The refund did not occur.  We have made a record of this in the problems log so that the situation can be corrected manually."
    } elseif { $refund_status == "inconclusive" } {
	set results_explanation "The results of the refund attempt were inconclusive (perhaps due to a communications failure between us and CyberCash.  A program will keep trying to complete the refund and the problems log will be updated if it the refund cannot be completed within 24 hours."
    } else {
	# refund successful
	db_dml update_ft_set_success "update ec_financial_transactions set refunded_date=sysdate where transaction_id=:transaction_id"
	set results_explanation "The refund is complete!"
    }

    set page_title "Refund completed with status $refund_status"

} else {
    set page_title "No credit card refund needed."
    set results_explanation "No credit card refund was necessary because the entire amount was refunded to the gift certificates the customer used when purchasing the order."
}

   

 
append doc_body "[ad_admin_header $page_title]
<h2>$page_title</h2>
[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index" "Orders"] [list "one?[export_url_vars order_id]" "One"] "Refund Complete"]

<hr>
<blockquote>
$results_explanation
<p>
<a href=\"one?[export_url_vars order_id]\">Back to Order $order_id</a>
</blockquote>

[ad_admin_footer]
"


doc_return  200 text/html $doc_body






