ad_page_contract { 
    @param spam_id
    @param subject
    @param message
    @param issue_type:multiple
    @param amount
    @param expires
    @param mailing_list:optional
    @param user_class_id:optional
    @param product_sku:optional
    @param start:optional
    @param end:optional
    @param user_id_list:optional,multiple
    @param viewed_product_sku:optional 
    @param category_id:optional
    @param show_users_p:optional

    @author
    @creation-date
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)

} { 
    spam_id:notnull
    subject:trim,notnull
    message:trim,notnull
    issue_type:multiple
    amount
    expires
    mailing_list:optional
    user_class_id:optional
    product_sku:optional
    start:optional
    end:optional
    user_id_list:optional,multiple
    viewed_product_sku:optional 
    category_id:optional
    show_users_p:optional
}

ad_require_permission [ad_conn package_id] admin

set issue_type_list $issue_type

# No confirm page because they were just sent through the spell
# checker (that's enough submits to push)

set expires_to_insert [ec_decode $expires "" "null" $expires]

# Get rid of stupid ^Ms

regsub -all "\r" $message "" message

# Doubleclick protection

if { [db_string get_log_entries_cnt "
    select count(*) 
    from ec_spam_log
    where spam_id = :spam_id"] > 0 } {
    
    append doc_body "
	[ad_admin_header "Spam Sent"]
	<h2>Spam Sent</h2>
	[ad_context_bar [list "../index.tcl" "Ecommerce([ec_system_name])"] [list "index.tcl" "Customer Service Administration"] "Spam Sent"]
	<hr>
	<p>You are seeing this page because you probably either hit reload or pushed the Submit button twice.</p>
	<p>If you wonder whether the users got the spam, just check the customer service issues for one of the users (all mail sent to a user is recorded as a customer service issue).</p>
	[ad_admin_footer]"
    ad_script_abort
}

set return_url "[ad_conn url]?[export_entire_form_as_url_vars]"
set customer_service_rep [ad_get_user_id]
if {$customer_service_rep == 0} {
    ad_returnredirect "/register.tcl?[export_url_vars return_url]"
    ad_script_abort
}

# 1. Write row to spam log
# 2. Select the users to be spammed
# 3. For each user:
#    a. create interaction
#    b. create issue
#    c. create action
#    d. send email
#    e. perhaps issue gift_certificate

set mailing_list_category_id ""
set mailing_list_subcategory_id ""
set mailing_list_subsubcategory_id ""

if { [info exists user_id_list] } {
    set users_query [db_map users_list]
} elseif { [info exists mailing_list] } {
    if { [llength $mailing_list] == 0 } {
	set search_criteria [db_map null_categories]
    } elseif { [llength $mailing_list] == 1 } {
	set search_criteria [db_map null_subcategory]
	set mailing_list_category_id $mailing_list
    } elseif { [llength $mailing_list] == 2 } {
	set search_criteria [db_map null_subsubcategory]
	set mailing_list_category_id [lindex $mailing_list 0]
	set mailing_list_subcategory_id [lindex $mailing_list 1]
    } else {
	set search_criteria [db_map null_subsubcategory]
	set mailing_list_category_id [lindex $mailing_list 0]
	set mailing_list_subcategory_id [lindex $mailing_list 1]
	set mailing_list_subsubcategory_id [lindex $mailing_list 2]
    }
    set users_query "[db_map users_email] and $search_criteria"
} elseif { [info exists user_class_id] } {
    if { ![empty_string_p $user_class_id]} {
	set users_query [db_map user_class]
    } else {
	set users_query [db_map all_users]
    }
} elseif { [info exists product_sku] } {
    set users_query [db_map bought_product]
} elseif { [info exists viewed_product_sku] } {
    set users_query 
} elseif { [info exists category_id] } {
    set users_query [db_map viewed_category]
} elseif { [info exists start] } {
    set users_query [db_map last_visit]
}

# Have to make all variables exist that will be inserted into
# ec_spam_log

if { ![info exists mailing_list_category_id] } {
    set mailing_list_category_id ""
}
if { ![info exists mailing_list_subcategory_id] } {
    set mailing_list_subcategory_id ""
}
if { ![info exists mailing_list_subsubcategory_id] } {
    set mailing_list_subsubcategory_id ""
}
if { ![info exists user_class_id] } {
    set user_class_id ""
}
if { ![info exists product_id] } {
    set product_id ""
}
if { ![info exists start] } {
    set start_date ""
} else {
    set start_date $start
}
if { ![info exists end] } {
    set end_date ""
} else {
    set end_date $end
}

db_transaction {

    db_dml insert_log_for_spam "
    insert into ec_spam_log
        (spam_id, spam_date, spam_text, mailing_list_category_id, 
         mailing_list_subcategory_id, mailing_list_subsubcategory_id, 
         user_class_id, product_id, 
         last_visit_start_date, last_visit_end_date)
    values
        (:spam_id, sysdate, :message, :mailing_list_category_id, 
         :mailing_list_subcategory_id, :mailing_list_subsubcategory_id, 
         :user_class_id, :product_id, 
         to_date(:start_date,'YYYY-MM-DD HH24:MI:SS'), 
         to_date(:end_date,'YYYY-MM-DD HH24:MI:SS'))"

    set sql $users_query

    append doc_body "
	[ad_admin_header "Spamming Users..."]
	<h2>Spamming Users...</h2>

	[ad_context_bar [list "../index.tcl" "Ecommerce([ec_system_name])"] [list "index.tcl" "Customer Service Administration"] "Spamming Users..."]

	<hr>
	<ul>"

    db_foreach get_users_for_spam $sql {
	
	# Create a customer service issue/interaction/action

	set user_identification_and_issue_id [ec_customer_service_simple_issue "" "automatic" "email" "To: $email\nFrom: [ad_parameter -package_id [ec_id] CustomerServiceEmailAddress ecommerce]\nSubject: $subject" "" $issue_type_list $message $user_id "" "f"]
	
	set user_identification_id [lindex $user_identification_and_issue_id 0]
	set issue_id [lindex $user_identification_and_issue_id 1]
	set email_from [ec_customer_service_email_address $user_identification_id $issue_id]
	
	ec_sendmail_from_service "$email" "$email_from" "$subject" "$message"

	if { ![empty_string_p $amount] && $amount > 0 } {

	    # Put a record into ec_gift_certificates and add the amount to
	    # the user's gift certificate account

	    db_dml insert_record_for_gift_certificates "
		insert into ec_gift_certificates
		(gift_certificate_id, user_id, amount, expires, issue_date, issued_by, gift_certificate_state, last_modified, last_modifying_user, modified_ip_address)
		values
		(ec_gift_cert_id_sequence.nextval, :user_id, :amount, $expires_to_insert, sysdate, :customer_service_rep, 'authorized', sysdate, :customer_service_rep, '[ns_conn peeraddr]') "
	}
	
	append doc_body "<li>Email has been sent to $email</li>"
    }

}

append doc_body "
    </ul>
    [ad_admin_footer]"

doc_return  200 text/html $doc_body




