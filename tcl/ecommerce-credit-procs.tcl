ad_library {

    Procedures related to credit card transactions for the ecommerce module

    @author Eve Andersson (eveander@arsdigita.com)
    @creation-date 1 April 1999
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @revision-date April 2002

}

ad_proc -public ec_creditcard_authorization { 
    order_id 
    {transaction_id ""} 
    {card_code ""}
} { 

    Authorizes the credit card for use with an order. Gets info it
    needs from database. Card_code does comes from mem to avoid storing in db.
    Connects to the payment gateway to
    authorize card. Outputs one of the following strings,
    corresponding to the level of authorization:

    (a) failed_authorization When the payment gateway declined
    authorization of the transaction. Or when no payment gateway has
    been selected.

    (b) authorized When the transaction is successfully authorized
    and passed the address verification.

    (c) no_recommendation When the payment gateway gives an error
    that is unrelated to the credit card used, such as timeout or
    failure-retry.

    (d) invalid_input When there are no orders with the given
    order_id or with no billing_zip. This case shouldn't
    happen, since this proc is called from a tcl script with a known
    order_id, and billing_zip shouldn't be null.

} {

    # Lookup the selected currency.

    set currency [ad_parameter Currency ecommerce]

    # Lookup the selected payment gateway

    set payment_gateway [ad_parameter PaymentGateway -default [ad_parameter -package_id [ec_id] PaymentGateway]]

    # Return an error when no payment gateway has been selected or if
    # there is no binding between the selected gateway and the
    # PaymentGateway.

    if {[empty_string_p $payment_gateway] || ![acs_sc_binding_exists_p "PaymentGateway" $payment_gateway]} {
        ns_log Warning "ec_creditcard_authorization (54):  payment gateway not bound to ecommerce package."
        set outcome(response_code) "failure"
        set outcome(transaction_id) "$transaction_id"
        return [array get outcome]
    }

    # Authorize the entire order when the transaction_id is null,
    # otherwise authorize the tranaction_amount.  

    # Leave order_id blank if you're using a transaction_id (useful
    # for gift certificates).
    
    if { [empty_string_p $transaction_id] } {
        db_1row order_data_select "
        select ec_order_cost(:order_id) as total_amount, 
        creditcard_id from ec_orders
        where order_id = :order_id"
    } else {
        db_1row transaction_data_select "
        select transaction_amount as total_amount, creditcard_id 
        from ec_financial_transactions 
        where transaction_id = :transaction_id"
    }

    # The order amount is 0 (zero) and there is thus no need
    # to contact the payment gateway. Record an instant
    # success.

    if {$total_amount == 0} {
        set outcome(response_code) "authorized"
        set outcome(transaction_id) "$transaction_id"
        return [array get outcome]
    }

    # Lookup the credit card for the transaction. Record an
    # invalid_input error if there isn't one.

    if {![db_0or1row creditcard_data_select "
        select c.creditcard_number as card_number, substring(creditcard_expire for 2) as card_exp_month, substring(creditcard_expire from 4 for 2) as card_exp_year, 
        c.creditcard_type, a.attn as card_name,
              a.zip_code as billing_zip,
              a.line1 as billing_address, 
          a.city as billing_city, 
              coalesce(a.usps_abbrev, a.full_state_name) as billing_state, 
              a.country_code as billing_country
        from ec_creditcards c, persons p, ec_addresses a 
        where c.user_id=p.person_id 
        and c.creditcard_id = :creditcard_id
        and c.billing_address = a.address_id"]} {
        set outcome(response_code) "invalid_input"
        set outcome(transaction_id) "$transaction_id"
        ns_log Error "ec_creditcard_authorization (105): no creditcard for transaction_id $transaction_id"
        return [array get outcome]
    } 

    # Generate a transaction_id if none has been provided.

    if { [empty_string_p $transaction_id] } {
        set transaction_id [db_string latest_transaction_select "
        select max(transaction_id) 
        from ec_financial_transactions 
        where order_id = :order_id"]
        ns_log Notice "ec_creditcard_authorization creating transaction_id ${transaction_id}"
    }

    # Convert the one digit creditcard abbreviation to the
    # standardized name of the card.

    set card_type [ec_pretty_creditcard_type $creditcard_type]
    ns_log Notice "ec_creditcard_authorization card_type ${card_type} from ${creditcard_type}"

    # card_code cvv2/cvc2/cid is not stored in the db
    # if needed, is passed into proc
   

    # Connect to the payment gateway to authorize the transaction.

    array set response [acs_sc_call "PaymentGateway" "Authorize" \
              [list $transaction_id \
               $total_amount \
               $card_type \
               $card_number \
               $card_exp_month \
               $card_exp_year \
               $card_code \
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
    ns_log Notice "ec_creditcard_authorization(150): response_code: ${response_code}"

    # Interpret the response_code.

    switch -exact $response_code {
    
        "failure" -
        "not_supported" -
        "not_implemented" {
        
        # The payment gateway rejected to authorize the
        # transaction. Or is not capable of authorizing
        # transactions.
        
            set outcome(response_code) "failed_authorization"
            set outcome(transaction_id) "$transaction_id"
            return [array get outcome]
        }
  
        "failure-retry" {
            
            # If the response_code is failure-retry, it means there was a
            # temporary failure that can be retried.  The order will be
            # retried the next time the scheduled procedure
            # ec_sweep_for_payment_zombies is run.
            
            set outcome(response_code) "no_recommendation"
            set outcome(transaction_id) "$transaction_id"
            return [array get outcome]
        } 
        
        "success" {
            
            # The payment gateway authorized the transaction.
            
            db_dml update_transaction_id "
        update ec_financial_transactions 
        set transaction_id = :pgw_transaction_id
        where transaction_id = :transaction_id"
            
            set outcome(response_code) "authorized"
            set outcome(transaction_id) "$pgw_transaction_id"
            return [array get outcome]
        }
        
        default {
            
            # Unknown response_code, fail the authorization to be on
            # the safe side.
            
            set outcome(response_code) "failured_authorization"
            set outcome(transaction_id) "$transaction_id"
            return [array get outcome]
        }
    }
}

ad_proc -public ec_creditcard_marking { 
    transaction_id 
    {card_code ""}
} { 
    
    Connect to the payment gateway to charge a previously authorized
    credit card for a transaction. This marks the transaction for
    settlement by the credit card gateway at the end of the day (or
    what ever time the gateway uses).

    Returns one of the following strings corresponding to whether or
    not the post authorization was successful:

    (a) success The outcome in most cases because there are few
    chances for failure

    (b) failure May occure when there is a communications failure
    with the payment gateway. Also, most payment gateways will fail
    a post authorization if the transaction has already been marked
    or if the post authorization amount is higher than the original
    authorized amount. Of course, the .tcl script that calls this
    proc shouldn't be trying to mark an transaction that's already
    been marked and, because the transaction amount is stored in the
    database , there should be no discrepancy in the authorized
    amount and the post authorization amount.

    (c) invalid_input Occurs if there is no transaction with the
    given transaction_id.  If case (c) occurs, then there is
    probably an error in the .tcl script that called this proc.

    (d) unknown This proc returns "unknown" if cases (a), (b) and
    (c) do not apply. And when a temporary error at the payment
    gateway failed the post authorization. 

} {

    # Lookup the selected currency.

    set currency [ad_parameter Currency ecommerce]

    # Lookup the selected payment gateway

    set payment_gateway [ad_parameter PaymentGateway]

    # Return an error when no payment gateway has been selected or if
    # there is no binding between the selected gateway and the
    # PaymentGateway.

    if {[empty_string_p $payment_gateway] || ![acs_sc_binding_exists_p "PaymentGateway" $payment_gateway]} {
        set outcome(response_code) "failure"
        set outcome(transaction_id) "$transaction_id"
        return [array get outcome]
    }

    # Retrieve the transaction amount from the database. NOTE The
    # transaction_id needed to charge the card is the transaction ID
    # returned by the payment gateway at the time of authorizing the
    # transaction.
 
    db_1row transaction_select "
    select f.transaction_amount, f.transaction_id, c.creditcard_type, a.attn card_name, 
        c.creditcard_number as card_number, substring(creditcard_expire for 2) as card_exp_month, substring(creditcard_expire from 4 for 2) as card_exp_year, c.creditcard_type, 
            a.zip_code as billing_zip,
            a.line1 as billing_address, 
            a.city as billing_city, 
            coalesce(a.usps_abbrev, a.full_state_name) as billing_state, 
            a.country_code as billing_country
    from ec_financial_transactions f, ec_creditcards c, persons p, ec_addresses a  
    where transaction_id = :transaction_id
    and f.creditcard_id = c.creditcard_id 
    and c.user_id = p.person_id
    and c.billing_address = a.address_id"

    # Fail the post authorization no transaction amount has been retrieved.

    if { [empty_string_p $transaction_amount] } {
        set outcome(response_code) "invalid_input"
        set outcome(transaction_id) "$transaction_id"
        return [array get outcome]
    }

    # The order amount is 0 (zero) and there is thus no need
    # to contact the payment gateway. Record an instant
    # success.

    if {$transaction_amount == 0 } {
        set outcome(response_code) "success"
        set outcome(transaction_id) "$transaction_id"
        return [array get outcome]
    } 

    # Convert the one digit creditcard abbreviation to the
    # standardized name of the card.

    set card_type [ec_pretty_creditcard_type $creditcard_type]

    # card_code cvv2/cvc2/cid is not stored in the db
    # if needed, needs to be passed in to proc

    # Connect to the payment gateway to authorize the transaction.

    array set response [acs_sc_call "PaymentGateway" "ChargeCard" \
              [list $transaction_id \
               $transaction_amount \
               $card_type \
               $card_number \
               $card_exp_month \
               $card_exp_year \
               $card_code \
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
        default {

            # The payment gateway rejected to post authorize the
            # transaction or returned an unknown response_code, fail the
            # post authorization to be on the safe side.
    
            set outcome(response_code) "failure"
            set outcome(transaction_id) "$transaction_id"
            return [array get outcome]
        }
        
        "failure-retry" -
        "not_supported" -
        "not_implemented" {
            
            # If the response_code is failure-retry, it means there was a
            # temporary failure that can be retried.  The order will be
            # retried the next time the scheduled procedure
            # ec_sweep_for_payment_zombies is run. Treat not_supported and
            # not_implemented responses the same.
            
            set outcome(response_code) "unknown"
            set outcome(transaction_id) "$transaction_id"
            return [array get outcome]
        }
        
        "success" {
            
            # The payment gateway approved the transaction.
            
            if { ![empty_string_p $pgw_transaction_id] } {
                db_dml update_transaction_id "
            update ec_financial_transactions 
            set transaction_id = :pgw_transaction_id
            where transaction_id = :transaction_id"
            }
            set outcome(response_code) "success"
            set outcome(transaction_id) "$pgw_transaction_id"
            return [array get outcome]
        }
    }
}

ad_proc -public ec_creditcard_return { 
    transaction_id 
    {card_code ""}
} { 

    Refunds a transaction back to the credit card used for that
    transaction.

    Returns one of the following strings corresponding to whether or
    not the marking was successful:

    (a) success The outcome in most cases because there are few
    chances for failure

    (b) failure May occure when there is a communications failure
    with the payment gateway. Also, most payment gateways will fail
    a return if the transaction has already been marked or if the
    return amount is higher than the original authorized amount. Of
    course, the .tcl script that calls this proc shouldn't be trying
    to mark an transaction that's already been marked and, because
    the transaction amount is stored in the database , there should
    be no discrepancy in the authorized amount and the return
    amount.

    (c) invalid_input Occurs if there is no transaction with the
    given transaction_id.  If case (c) occurs, then there is
    probably an error in the .tcl script that called this proc.

    (d) unknown This proc returns "unknown" if cases (a), (b) and
    (c) do not apply. And when a temporary error at the payment
    gateway failed the return.

} {

    # Lookup the selected currency.

    set currency [ad_parameter Currency ecommerce]

    # Lookup the selected payment gateway

    set payment_gateway [ad_parameter PaymentGateway]

    # Return an error when no payment gateway has been selected or if
    # there is no binding between the selected gateway and the
    # PaymentGateway.

    if {[empty_string_p $payment_gateway] || ![acs_sc_binding_exists_p "PaymentGateway" $payment_gateway]} {
        set outcome(response_code) "failure"
        set outcome(transaction_id) "$transaction_id"
        return [array get outcome]
    }

    # Retrieve the transaction amount and the credit card information
    # of the card used for the transaction from the database. NOTE The
    # transaction_id needed to charge the card is the transaction ID
    # returned by the payment gateway at the time of authorizing the
    # transaction.

    if {![db_0or1row transaction_info_select "
             select t.refunded_transaction_id, t.transaction_amount, 
        c.creditcard_number as card_number, substring(creditcard_expire for 2) as card_exp_month, substring(creditcard_expire from 4 for 2) as card_exp_year, c.creditcard_type,
        a.attn as card_name, 
              a.zip_code as billing_zip,
              a.line1 as billing_address, 
              a.city as billing_city, 
              coalesce(a.usps_abbrev, a.full_state_name) as billing_state, 
              a.country_code as billing_country
             from ec_financial_transactions t, ec_creditcards c, persons p, ec_addresses a  
             where t.transaction_id = :transaction_id 
             and c.creditcard_id = t.creditcard_id
         and c.user_id = p.person_id
               and c.billing_address = a.address_id"]} {
        set outcome(response_code) "invalid_input"
        set outcome(transaction_id) "$transaction_id"
        return [array get outcome]
    } 

    # The order amount is 0 (zero) and there is thus no need
    # to contact the payment gateway. Record an instant
    # success.
    
    if { $transaction_amount == 0 } {
        set outcome(response_code) "success"
        set outcome(transaction_id) "$transaction_id"
        return [array get outcome]
    } 

    # Convert the one digit creditcard abbreviation to the
    # standardized name of the card.

    set card_type [ec_pretty_creditcard_type $creditcard_type]

    # card_code cvv2/cvc2/cid is not stored in the db
    # if needed, must be passed into proc

    # Connect to the payment gateway to authorize the transaction.

    array set response [acs_sc_call "PaymentGateway" "Return" \
              [list $refunded_transaction_id \
               $transaction_amount \
               $card_type \
               $card_number \
               $card_exp_month \
               $card_exp_year \
               $card_code \
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
        default {
            
            # The payment gateway rejected to refund the transaction or
            # returned an unknown response_code. Fail the post
            # authorization to be on the safe side.
            
            db_dml transaction_failure_update "
        update ec_financial_transactions 
        set failed_p = 't'
        where transaction_id = :transaction_id"
            
            set outcome(response_code) "failure"
            set outcome(transaction_id) "$transaction_id"
            return [array get outcome]
        }
        
        "failure-retry" -
        "not_supported" -
        "not_implemented" {
            
            # If the response_code is failure-retry, it means there was a
            # temporary failure that can be retried.  The order will be
            # retried the next time the scheduled procedure
            # ec_sweep_for_payment_zombies is run. Treat not_supported and
            # not_implemented responses the same.
            
            set outcome(response_code) "unknown"
            set outcome(transaction_id) "$transaction_id"
            return [array get outcome]
        } 
        
        "success" {
            
            # The payment gateway authorized the transaction.
            
            db_dml transaction_success_update "
        update ec_financial_transactions 
        set transaction_id = :pgw_transaction_id, refunded_date = sysdate
        where transaction_id = :transaction_id"
            
            set outcome(response_code) "success"
            set outcome(transaction_id) "$pgw_transaction_id"
            return [array get outcome]
        }
    }
}

ad_proc -public ec_creditcard_precheck { 
    creditcard_number 
    creditcard_type 
    {creditcard_code ""}
} { 
    
    Prechecks credit card numbers. If you're going to accept cards
    other than MasterCard, Visa, or American Express, you'll have to
    modify this proc to recognize them.  It should be easy; just
    look at the proc ec_creditcard_validation to see how different
    card numbers are formed. 

    This script does some basic checks on the credit card and
    returns a list containing exception_count, exception_text.  

    The creditcard_number shouldn't contain any special characters;
    numbers only. The check to see whether the creditcard_number or
    creditcard_type is the empty string should be done separately.

    m = mastercard,
    v = visa,
    a = american express
    n = discover / novus
} {

    set exception_count 0
    set exception_text ""
    set card_code_required [parameter::get -package_id [ec_id] -parameter PaymentCardCodeRequired -default 0]

    if {![empty_string_p $creditcard_type]} {
        switch -exact $creditcard_type {
            
            "m" {
                if {[string index $creditcard_number 0] != 5} {
                    incr exception_count
                    append exception_text "<li>The credit card number is not a MasterCard number.</li>"
                }
                if {[string length $creditcard_number] != 16} {
                    incr exception_count
                    append exception_text "<li>The credit card number does not have the right number of digits.</li>"
                }
                if { $card_code_required && [string length $creditcard_code] != 3 } {
                    incr exception_count
                    append exception_text "<li>The credit card validation code (CVC2) should have 3 digits, and is usually a separate group of 3 digits to the right of the signature strip.</li>"
                }
                
            }
            
            "v" {
                if {[string index $creditcard_number 0] != 4} {
                    incr exception_count
                    append exception_text "<li>The credit card number is not a VISA number.</li>"
                }
                if {[string length $creditcard_number] != 16 && [string length $creditcard_number] != 13} {
                    incr exception_count
                    append exception_text "<li>The credit card number does not have the right number of digits.</li>"
                }            
                if { $card_code_required && [string length $creditcard_code] != 3 } {
                    incr exception_count
                    append exception_text "<li>The credit card verification value (CVV2) should have 3 digits, and is usually a separate group of 3 digits to the right of the signature strip.</li>"
                }
                
            }
            
            "a" {
                if {[string index $creditcard_number 0] != 3} {
                    incr exception_count
                    append exception_text "<li>The credit card number is not an American Express number.</li>"
                }
                if {[string length $creditcard_number] != 15} {
                    incr exception_count
                    append exception_text "<li>The credit card number does not have the right number of digits.</li>"
                }            
                if { $card_code_required && [string length $creditcard_code] != 4 } {
                    incr exception_count
                    append exception_text "<li>The credit card Unique Card Code (CID) should have 4 digits, and is a printed group of four digits on the right side of the face of the card.</li>"
                }
                
            }
            
            "n" {
                # no pattern available to precheck validity of card
                if { $card_code_required && [string length $creditcard_code] != 3 } {
                    incr exception_count
                    append exception_text "<li>The credit card identification number (CID) should have 3 digits, and is usually a separate group of 3 digits to the right of the signature strip.</li>"
                }
                
            }
            
            default {
                incr exception_count
                append exception_text "<li> Sorry, the credit card type is of an unknown type: [ec_pretty_creditcard_type $creditcard_type].</li>"
                ns_log Warning "ec_creditcard_precheck: Possible configuration error. Rejected a user supplied creditcard as unknown."
            }
        }
    }
    
    # Only if there haven't been any problems so far should we do
    # LUHN-10 error checking which the customer is less likely to
    # understand
    
    if { $exception_count == 0 } {
        set decoded_creditcard_type [ec_creditcard_validation $creditcard_number]
        set vallas_creditcard_type [ec_pretty_creditcard_type $creditcard_type]
        
        if {$decoded_creditcard_type == "unknown" } {
            incr exception_count
            append exception_text "
        <li>
          The credit card number is of an unknown credit card type while the card is a(n) [ec_pretty_creditcard_type $creditcard_type] credit card.
        </li>"
        } else {
            if { $vallas_creditcard_type != $vallas_creditcard_type } {
                incr exception_count
                append exception_text "
            <li>
              The credit card number is a(n) $decoded_creditcard_type number while the card is a(n) [ec_pretty_creditcard_type $creditcard_type] credit card.
            </li>"
            }
        }
    }
    return [list $exception_count $exception_text]
}

ad_proc -private ec_creditcard_validation {
    numIn
} { 
    
    This procedure validates a credit card number. It was originally
    called valCC, and was written by Horace Vallas. The original was
    found at http://www.hav.com/valCC/nph-src.htm?valCC.nws (with an
    HTML demo at
    https://enterprise.neosoft.com/secureforms/hav/default.htm).  It
    has been left unchanged except for the name.
    eveander@arsdigita.com
    
    H.V.'s comments:

    This is a demo NeoWebScript by Horace Vallas (3-7-97) according
    to some info I found on the web that was attibuted to ICVERIFY
    by Hal Stiles hstiles@beachnet.com
    http://www.beachnet.com/~hstiles/cardtype.html. You are welcome
    to use it; however, I make no warranty whatsoever about the
    accuracy or usefullness of this script. By using this script,
    you are agreeing that I am not responsible for any damage, of
    any kind whatsoever, to you or to any of your customers,
    clients, partners, friends, relatives, children born or unborne,
    pets, invisible friends, etc. etc. etc.

    The valCC proc can be used to validate a credit card number as
    being legally formed.

    Input is the entered card number.

    Return is the type of card (if validated) or "- unknown-" if it
    is an unknown or invalid number

    The validation applied (last known date 3/96) is the so called
    LUHN Formula (Mod 10) for Validation of Primary Account Number.

    Validation criteria are:
      1. number prefix
      2. number of digits
      3. mod10  (for all but enRoute which uses only 1 & 2)

    Each card type has the following criteria requirements:
    
    Card Type        Prefix            Length    Check-Digit Algoritm
    
    MC                51 - 55              16        mod 10
    
    VISA        4            13, 16        mod 10
    
    AMX                34, 37              15        mod 10
    
    Diners Club /    300 - 305, 36, 38      14        mod 10
    Carte Blanche
    
    Discover            6011              16        mod 10
    
    enRoute        2014, 2149          16        - any -
    
    JCB                3              16        mod 10
    JCB                2131, 1800          15        mod 10

} {

    # Remove all spaces from the credit card number.

    regsub -all { } $numIn {} entered_number

    # Convert the credit card number to list of the digits in the
    # number.

    set num [split $entered_number {}]

    # Get the number of digits in the credit card number.

    set numLen [llength $num]

    # Set the default card type to unknown.

    set type "-unknown-"

    # First determine the type of card: MC, VISA, AMX, etc. by testing
    # the first 4 digits of the credit card number and then the total
    # number of digits of the credit number.

    switch -glob [string range $entered_number 0 3] {

        "51??" -  
        "52??" -  
        "53??" -  
        "54??" -  
        "55??" {
            if {$numLen == 16} {
                set type "MasterCard"
            }
        }
        
        "4???" {
            if {$numLen == 13 || $numLen == 16} {
                set type "VISA"
            }
        }
        
        "34??" -  
        "37??" {
            if {$numLen == 15}  {
                set type "American Express"
            }
        }
        
        "300?" -  
        "301?" -  
        "302?" -  
        "303?" - 
        "304?" - 
        "305?" -  
        "36??" -   
        "38??" {
            if {$numLen == 14} {
                set type "Diners Club"
            }
        }
        
        "6011" {
            if {$numLen == 16} {
                set type "Discover/Novus"
            }
        }
        
        "2014" -  
        "2149" {
            if {$numLen == 15} {
                set type "enRoute"
            }
            
            # early exit for enRoute
            
            return $type  
        }
        
        "3???" {
            if {$numLen == 16} {
                set type "JCB"
            }
        }
        
        "2131" -  
        "1800" {
            if {$numLen == 15} {
                set type "JCB"
            }
        }
        
        default {
            set type "-unknown-"
        }
    }
    
    # Early exit if card type is unknown.
    
    if {$type == "-unknown-"} {
        return $type
    } 
    
    # If prefix and number of digits are ok, then apply the mod10
    # check. Initialize the running sum
    
    set sum 0
    
    # Sum every digit starting with the RIGHT-MOST digit on alternate
    # digits (starting with the NEXT-TO-THE-RIGHT-MOST digit). Then
    # sum all digits in the result of TWO TIMES the alternate digit
    # RATHER than the original digit itself. Catch this summing loop
    # in case there are non-digit values in the credit card number.
    
    if {[catch { 
        for {set i [expr $numLen - 1]} {$i >= 0} {} {
            incr sum [lindex $num $i]
            if {[incr i -1] >= 0} {
                foreach adigit [split [expr 2 * [lindex $num $i]] {}] {
                    incr sum $adigit
                }
                incr i -1
            }
        } }] !=  0} {
        return "-unknown-"
    }
    
    # Emulate a mod 10 (base 10) on the calculated number. If there is
    # any remainder, then the number IS NOT VALID so reset type to
    # -unknown-
    
    set lsum [split $sum {}]
    if {[lindex $lsum [expr [llength $lsum] - 1]]} {
        set type "-unknown-"
    }
    
    return $type
}
