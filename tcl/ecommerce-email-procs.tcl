ad_library {

    Email procedures for the ecommerce module
    Started April, 1999 by Eve Andersson (eveander@arsdigita.com)
    Other ecommerce procedures can be found in ecommerce-*.tcl

    @author Eve Andersson (eveander@arsdigita.com)
    @creation-date Summer 1999
    @author ported by Jerry Asher (jerry-ecommerce@hollyjerry.org)
    @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @revision-date April 2002
}

ad_proc ec_sendmail_from_service { 
    email_to 
    reply_to 
    email_subject
    email_body
    {additional_headers ""} 
    {bcc ""} 
} {
    Use this when you're sending out customer service emails.  It's
    invoked just like ns_sendmail, except that the email will always
    be from the customer service email address.  The reply-to field
    can be used for the perl/qmail service-345-9848@whatever.com
    email trick (but it doesn't have to be).<p>Note: one major
    difference from ns_sendmail: with ns_sendmail, putting a Cc
    header does not actually send an extra copy of the email; it
    just puts Cc: whomever@wherever into the header (and then you'd
    have to specify whomever@wherever in the bcc argument).  This
    procedure does send the email to the Cc'd email addresses.
} {

    set extra_headers [ns_set new]
    ns_set put $extra_headers "Reply-to" $reply_to
    
    if { $bcc != "" } {
	ns_set put $extra_headers "Bcc" $bcc
    }
    
    if { $additional_headers != "" } {
	ns_set merge $extra_headers $additional_headers
    }

    set from "\"[ad_parameter -package_id [ec_id] CustomerServiceEmailDescription ecommerce]\" <$reply_to>"
    qmail $email_to $from $email_subject $email_body $extra_headers
}

ad_proc ec_email_new_order { 
    order_id 
} {
    Use this to send out the \"New Order\" email.
} {
    if {[db_0or1row email_info_select "
	select u.email, to_char(confirmed_date,'MM/DD/YY') as confirmed_date, shipping_address, u.user_id
	from ec_orders, cc_users u
	where ec_orders.user_id = u.user_id
	and order_id = :order_id"]} {

	set item_summary [ec_item_summary_in_confirmed_order $order_id]
	
	if { ![empty_string_p $shipping_address] } {
	    set address [ec_pretty_mailing_address_from_ec_addresses $shipping_address]
	} else {
	    set address "not deliverable"
	}
    
	set price_summary [ec_formatted_price_shipping_gift_certificate_and_tax_in_an_order $order_id]
	
	set customer_service_signature [ec_customer_service_signature]
	set system_url "[ec_insecure_location][ec_url]"

	# Have to get rid of ampersands in above variables because
	# they # mess up regsubs

	regsub -all -- "&" $price_summary {\\&} price_summary
	regsub -all -- "&" $item_summary {\\&} item_summary
	regsub -all -- "&" $address {\\&} address
	regsub -all -- "&" $customer_service_signature {\\&} customer_service_signature
	regsub -all -- "&" $system_url {\\&} system_url
    
	# Note: template #1 is defined to be the "New Order" email

	db_1row template_select_1 "
	    select subject as email_subject, message as email_body, issue_type_list
	    from ec_email_templates
	    where email_template_id = 1"

	# And get rid of ctrl-M's in the body

	regsub -all -- "\r" $email_body "" email_body

	regsub -all -- "confirmed_date_here" $email_body $confirmed_date email_body
	regsub -all -- "item_summary_here" $email_body $item_summary email_body
	regsub -all -- "address_here" $email_body $address email_body
	regsub -all -- "price_summary_here" $email_body $price_summary email_body
	regsub -all -- "customer_service_signature_here" $email_body $customer_service_signature email_body
	regsub -all -- "system_url_here" $email_body $system_url email_body

	db_transaction {

	    # Create a customer service issue/interaction/action

	    set user_identification_and_issue_id [ec_customer_service_simple_issue "" "automatic" "email" \
						      "To: $email\nFrom: [ad_parameter -package_id [ec_id] CustomerServiceEmailAddress ecommerce]\nSubject: $email_subject" \
						      $order_id $issue_type_list $email_body $user_id]

	    set user_identification_id [lindex $user_identification_and_issue_id 0]
	    set issue_id [lindex $user_identification_and_issue_id 1]
	    if { [empty_string_p $user_identification_id] } { 
		set user_identification_id 0
	    }

	    # Add a row to the automatic email log

	    db_dml email_log_insert_1 "
		insert into ec_automatic_email_log
		(user_identification_id, email_template_id, order_id, date_sent)
		values
		(:user_identification_id, 1, :order_id, sysdate)"
	}

	set email_from [ec_customer_service_email_address $user_identification_id $issue_id]
	
	ec_sendmail_from_service "$email" "$email_from" "$email_subject" "$email_body"
	ec_email_product_notification $order_id
    }
}

ad_proc ec_email_product_notification { 
    order_id 
} {
    This proc sends notifications for any products in the order that
    require it.
} {

    set order_link [ec_securelink "[ad_url][ec_url]admin/orders/one?[export_vars order_id]"]

    db_foreach notification_select {
	select ep.email_on_purchase_list, ep.product_name
	from ec_items ei, ec_products ep
	where ei.product_id = ep.product_id
	and ei.order_id = :order_id
	group by ep.email_on_purchase_list, ep.product_name
    } {
	set email_from [ec_customer_service_email_address]
	ec_sendmail_from_service $email_on_purchase_list $email_from "An order for $product_name" "
An order for $product_name has been placed at [ec_system_name].

The order can be viewed at:

$order_link
"
    }
}

ad_proc ec_email_delayed_credit_denied { 
    order_id 
} {
    Use this to send out the \"Delayed Credit Denied\" email.
} {
    
    if {[db_0or1row user_select "
	select u.email, u.user_id
	from ec_orders, cc_users u
	where ec_orders.user_id = u.user_id
	and order_id = :order_id"]} {

	set customer_service_signature [ec_customer_service_signature]
	set system_url "[ec_insecure_location][ec_url]"

	# Have to get rid of ampersands in above variables because
	# they mess up regsubs

	regsub -all -- "&" $customer_service_signature {\\&} customer_service_signature
	regsub -all -- "&" $system_url {\\&} system_url
	
	# Note: template #3 is defined to be the "Delayed Credit
	# Denied" email

	db_1row template_select_3 "
	    select subject as email_subject, message as email_body, issue_type_list
	    from ec_email_templates
	    where email_template_id = 3"

	# And get rid of ctrl-M's in the body

	regsub -all -- "\r" $email_body "" email_body
	regsub -all -- "customer_service_signature_here" $email_body $customer_service_signature email_body
	regsub -all -- "system_url_here" $email_body $system_url email_body

	db_transaction {

	    # Create a customer service issue/interaction/action

	    set user_identification_and_issue_id [ec_customer_service_simple_issue "" "automatic" "email" \ 
						  "To: $email\nFrom: [ad_parameter -package_id [ec_id] CustomerServiceEmailAddress ecommerce]\nSubject: $email_subject" \
						      $order_id $issue_type_list $email_body $user_id]

	    set user_identification_id [lindex $user_identification_and_issue_id 0]
	    set issue_id [lindex $user_identification_and_issue_id 1]

	    # Add a row to the automatic email log

	    db_dml email_log_insert_3 "
		insert into ec_automatic_email_log
		(user_identification_id, email_template_id, order_id, date_sent)
		values
		(:user_identification_id, 3, :order_id, sysdate)"

	}
	set email_from [ec_customer_service_email_address $user_identification_id $issue_id]
	ec_sendmail_from_service "$email" "$email_from" "$email_subject" "$email_body"
    }
}

ad_proc ec_email_order_shipped { 
    shipment_id 
} {
    Use this to send out the \"Order Shipped\" email after a
    shipment is made (full or partial order).
} {
    
    if {[db_0or1row shipment_select "
	select u.email, u.user_id, s.shipment_date, s.address_id, o.order_state, o.order_id
	from ec_orders o, cc_users u, ec_shipments s
	where o.user_id = u.user_id
	and o.order_id = s.order_id
	and s.shipment_id = :shipment_id"]} {

	set shipped_date [util_AnsiDatetoPrettyDate $shipment_date]

	# Get item_summary

	set item_list [list]
	db_foreach item_summary_select "
	    select p.product_name, p.one_line_description, p.product_id, i.price_charged, i.price_name, count(*) as quantity
	    from ec_items i, ec_products p
	    where i.product_id=p.product_id
	    and i.shipment_id=:shipment_id
	    group by p.product_name, p.one_line_description, p.product_id, i.price_charged, i.price_name" {
	    lappend item_list "Quantity $quantity: $product_name; $price_name: [ec_pretty_price $price_charged]"
	}

	set item_summary [join $item_list "\n"]
	set address [ec_pretty_mailing_address_from_ec_addresses $address_id]

	# See whether this completes the order

	if { $order_state == "fulfilled" } {
	    set order_completion_sentence "This completes your order."
	} else {
	    set order_completion_sentence "There is still more to come.  We will let you know when\nthe rest of your order ships."
	}

	set customer_service_signature [ec_customer_service_signature]
	set system_url "[ec_insecure_location][ec_url]"

	# Have to get rid of ampersands in above variables because
	# they mess up regsubs

	regsub -all -- "&" $item_summary {\\&} item_summary
	regsub -all -- "&" $address {\\&} address
	regsub -all -- "&" $order_completion_sentence {\\&} order_completion_sentence
	regsub -all -- "&" $customer_service_signature {\\&} customer_service_signature
	regsub -all -- "&" $system_url {\\&} system_url
	
	# Note: template #2 is defined to be the "Order Shipped" email

	db_1row template_select_2 "
	    select subject as email_subject, message as email_body, issue_type_list 
	    from ec_email_templates
	    where email_template_id = 2"

	# And get rid of ctrl-M's in the body

	regsub -all -- "\r" $email_body "" email_body
	regsub -all -- "shipped_date_here" $email_body $shipped_date email_body
	regsub -all -- "item_summary_here" $email_body $item_summary email_body
	regsub -all -- "address_here" $email_body $address email_body
	regsub -all -- "sentence_about_whether_this_completes_the_order_here" $email_body $order_completion_sentence email_body
	regsub -all -- "customer_service_signature_here" $email_body $customer_service_signature email_body
	regsub -all -- "system_url_here" $email_body $system_url email_body

	db_transaction {

	    # Create a customer service issue/interaction/action

	    set user_identification_and_issue_id [ec_customer_service_simple_issue "" "automatic" "email" \
						      "To: $email\nFrom: [ad_parameter -package_id [ec_id] CustomerServiceEmailAddress ecommerce]\nSubject: $email_subject" \
						      $order_id $issue_type_list $email_body $user_id]

	    set user_identification_id [lindex $user_identification_and_issue_id 0]
	    set issue_id [lindex $user_identification_and_issue_id 1]

	    # Add a row to the automatic email log

	    db_dml email_log_insert_2 "
		insert into ec_automatic_email_log
		(user_identification_id, email_template_id, order_id, shipment_id, date_sent)
		values
		(:user_identification_id, 2, :order_id, :shipment_id, sysdate)"
	}
	set email_from [ec_customer_service_email_address $user_identification_id $issue_id]
	ec_sendmail_from_service "$email" "$email_from" "$email_subject" "$email_body"
    }	
}

ad_proc ec_email_new_gift_certificate_order { 
    gift_certificate_id 
} {

    Use this to send out the \"New Gift Certificate Order\" email
    after a gift certificate order is authorized.

} {
    if {[db_0or1row gift_certificate_select "
	select g.purchased_by as user_id, u.email, g.recipient_email, g.amount
	from ec_gift_certificates g, cc_users u
	where g.purchased_by=u.user_id
	and g.gift_certificate_id = :gift_certificate_id"]} {
	
	set system_name [ad_system_name]
	set customer_service_signature [ec_customer_service_signature]

	# Have to get rid of ampersands in above variables because
	# they mess up regsubs

	regsub -all -- "&" $recipient_email {\\&} recipient_email
	regsub -all -- "&" $system_name {\\&} system_name
	regsub -all -- "&" $customer_service_signature {\\&} customer_service_signature
	
	# Note: template #4 is defined to be the "New Gift Certificate
	# Order" email

	db_1row template_select_4 "
	    select subject as email_subject, message as email_body, issue_type_list 
	    from ec_email_templates
	    where email_template_id = 4"

	# And get rid of ctrl-M's in the body

	regsub -all -- "\r" $email_body "" email_body

	regsub -all -- "system_name_here" $email_body $system_name email_body
	regsub -all -- "recipient_email_here" $email_body $recipient_email email_body
	regsub -all -- "certificate_amount_here" $email_body [ec_pretty_price $amount] email_body
	regsub -all -- "customer_service_signature_here" $email_body $customer_service_signature email_body

	db_transaction {

	    # Create a customer service issue/interaction/action

	    set user_identification_and_issue_id [ec_customer_service_simple_issue "" "automatic" "email" \
						      "To: $email\nFrom: [ad_parameter -package_id [ec_id] CustomerServiceEmailAddress ecommerce]\nSubject: $email_subject" \
						      "" $issue_type_list $email_body $user_id "" "f" $gift_certificate_id]

	    set user_identification_id [lindex $user_identification_and_issue_id 0]
	    set issue_id [lindex $user_identification_and_issue_id 1]

	    # Add a row to the automatic email log

	    db_dml email_log_insert_4 "
		insert into ec_automatic_email_log
		(user_identification_id, email_template_id, gift_certificate_id, date_sent)
		values
		(:user_identification_id, 4, :gift_certificate_id, sysdate)" 
	}

	set email_from [ec_customer_service_email_address $user_identification_id $issue_id]
	
	ec_sendmail_from_service "$email" "$email_from" "$email_subject" "$email_body"
    }
}

ad_proc ec_email_gift_certificate_order_failure { 
    gift_certificate_id 
} {
    Use this to send out the \"Gift Certificate Order Failure\"
    email after it is determined that a previously inconclusive auth
    failed.
} {
    if {[db_0or1row gift_certificate_select_2 "
	select g.purchased_by as user_id, u.email, g.recipient_email, g.amount, g.certificate_to, g.certificate_from, g.certificate_message
	from ec_gift_certificates g, cc_users u
	where g.purchased_by=u.user_id
	and g.gift_certificate_id=:gift_certificate_id"]} {
	
	set system_name [ad_system_name]
	set system_url "[ec_insecure_location][ec_url]"
	set customer_service_signature [ec_customer_service_signature]

	set amount_and_message_summary ""
	if { ![empty_string_p $certificate_to] } {
	    append amount_and_message_summary "To:     $certificate_to\n"
	}
	append amount_and_message_summary "Amount: [ec_pretty_price $amount]\n"
	if { ![empty_string_p $certificate_from] } {
	    append amount_and_message_summary "From:   $certificate_from\n"
	}
	if { ![empty_string_p $certificate_message] } {
	    append amount_and_message_summary "Message:\n$certificate_message\n"
	}

	# Have to get rid of ampersands in above variables because they
	# mess up regsubs

	regsub -all -- "&" $system_name {\\&} system_name
	regsub -all -- "&" $system_url {\\&} system_url
	regsub -all -- "&" $recipient_email {\\&} recipient_email
	regsub -all -- "&" $amount_and_message_summary {\\&} amount_and_message_summary
	regsub -all -- "&" $customer_service_signature {\\&} customer_service_signature
	

	# Note: template #6 is defined to be the "Gift Certificate Order
	# Failure" email

	db_1row template_select_6 "
	    select subject as email_subject, message as email_body, issue_type_list
	    from ec_email_templates
	    where email_template_id = 6"

	# And get rid of ctrl-M's in the body

	regsub -all -- "\r" $email_body "" email_body

	regsub -all -- "system_name_here" $email_body $system_name email_body
	regsub -all -- "system_url_here" $email_body $system_url email_body
	regsub -all -- "recipient_email_here" $email_body $recipient_email email_body
	regsub -all -- "amount_and_message_summary_here" $email_body $amount_and_message_summary email_body
	regsub -all -- "customer_service_signature_here" $email_body $customer_service_signature email_body

	db_transaction {

	    # Create a customer service issue/interaction/action

	    set user_identification_and_issue_id [ec_customer_service_simple_issue "" "automatic" "email" \
						      "To: $email\nFrom: [ad_parameter -package_id [ec_id]  CustomerServiceEmailAddress ecommerce]\nSubject: $email_subject" \
						      "" $issue_type_list $email_body $user_id "" "f" $gift_certificate_id]

	    set user_identification_id [lindex $user_identification_and_issue_id 0]
	    set issue_id [lindex $user_identification_and_issue_id 1]

	    # Add a row to the automatic email log

	    db_dml email_log_insert_6 "
		insert into ec_automatic_email_log
		(user_identification_id, email_template_id, gift_certificate_id, date_sent)
		values
		(:user_identification_id, 6, :gift_certificate_id, sysdate)"
	}

	set email_from [ec_customer_service_email_address $user_identification_id $issue_id]
	ec_sendmail_from_service "$email" "$email_from" "$email_subject" "$email_body"
    }
}

# in this email, the recipient isn't necessarily a user of the system, so the customer service issue
# creation code is a little different than in the other autoemails

ad_proc ec_email_gift_certificate_recipient { 
    gift_certificate_id 
} {
    Use this to send out the \"Gift Certificate Recipient\" email
    after it a purchased certificate is authorized.
} {

    if {[db_0or1row gift_certificate_select_3 "
	select g.recipient_email as email, g.amount, g.certificate_to, g.certificate_from, g.certificate_message, g.claim_check
	from ec_gift_certificates g
	where g.gift_certificate_id=:gift_certificate_id"]} {
    
	set system_name [ad_system_name]
	set system_url "[ec_insecure_location][ec_url]"
	set customer_service_signature [ec_customer_service_signature]

	set amount_and_message_summary ""
	if { ![empty_string_p $certificate_to] } {
	    append amount_and_message_summary "To:     $certificate_to\n"
	}
	append amount_and_message_summary "Amount: [ec_pretty_price $amount]\n"
	if { ![empty_string_p $certificate_from] } {
	    append amount_and_message_summary "From:   $certificate_from\n"
	}
	if { ![empty_string_p $certificate_message] } {
	    append amount_and_message_summary "Message:\n$certificate_message\n"
	}

	# Have to get rid of ampersands in above variables because
	# they mess up regsubs

	regsub -all -- "&" $system_name {\\&} system_name
	regsub -all -- "&" $system_url {\\&} system_url
	regsub -all -- "&" $amount_and_message_summary {\\&} amount_and_message_summary
	regsub -all -- "&" $claim_check {\\&} claim_check
	regsub -all -- "&" $customer_service_signature {\\&} customer_service_signature
	

	# Note: template #5 is defined to be the "Gift Certificate
	# Recipient" email

	db_1row template_select_5 "
	    select subject as email_subject, message as email_body, issue_type_list 
	    from ec_email_templates
	    where email_template_id=5"

	# And get rid of ctrl-M's in the body

	regsub -all -- "\r" $email_body "" email_body
	regsub -all -- "system_name_here" $email_body $system_name email_body
	regsub -all -- "system_url_here" $email_body $system_url email_body
	regsub -all -- "amount_and_message_summary_here" $email_body $amount_and_message_summary email_body
	regsub -all -- "claim_check_here" $email_body $claim_check email_body
	regsub -all -- "customer_service_signature_here" $email_body $customer_service_signature email_body

	# First let's see if the recipient is a registered user of the
	# system

	set user_id [db_string user_id_select "
	    select user_id
	    from cc_users
	    where email=lower(:email) " -default ""]

	db_transaction {

	    # Create a customer service issue/interaction/action

	    if { ![empty_string_p $user_id] } {
		set user_identification_and_issue_id [ec_customer_service_simple_issue "" "automatic" "email" \
							  "To: $email\nFrom: [ad_parameter -package_id [ec_id] CustomerServiceEmailAddress ecommerce]\nSubject: $email_subject" \
							  "" $issue_type_list $email_body $user_id "" "f" $gift_certificate_id]
		set user_identification_id [lindex $user_identification_and_issue_id 0]
	    } else {

		# Check if the recipient is an unregistered user of
		# the system

		set user_identification_id [db_string user_identification_id_select "select user_identification_id from ec_user_identification where email=lower(:email)" -default ""]

		if { [empty_string_p $user_identification_id] } {
		    set user_identification_id [db_nextval ec_user_ident_id_sequence]
		    set trimmed_email [string trim $email]

		    db_dml user_identification_id_insert "
			insert into ec_user_identification
			(user_identification_id, email)
			values
			(:user_identification_id, :trimmed_email)"
		}

		set user_identification_and_issue_id [ec_customer_service_simple_issue "" "automatic" "email" \
							  "To: $email\nFrom: [ad_parameter -package_id [ec_id] CustomerServiceEmailAddress ecommerce]\nSubject: $email_subject" \
							  "" $issue_type_list $email_body "" $user_identification_id "f" $gift_certificate_id]
	    }

	    set issue_id [lindex $user_identification_and_issue_id 1]

	    # Add a row to the automatic email log

	    db_dml email_log_insert_5 "
		insert into ec_automatic_email_log
		(user_identification_id, email_template_id, gift_certificate_id, date_sent)
		values
		(:user_identification_id, 5, :gift_certificate_id, sysdate)"
	}
	set email_from [ec_customer_service_email_address $user_identification_id $issue_id]
	ec_sendmail_from_service "$email" "$email_from" "$email_subject" "$email_body"
    }
}
