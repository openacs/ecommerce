# spam-3.tcl

ad_page_contract { 
    @param spam_id
    @param subject
    @param message
    @param issue_type:multiple
    @param amount
    @param expires
    @param mailing_list:optional
    @param user_class_id:optional
    @param product_id:optional
    @param start_date:optional
    @param end_date:optional
    @param user_id_list:optional,multiple
    @param viewed_product_id:optional 
    @param category_id:optional
    @param show_users_p:optional

    @author
    @creation-date
    @cvs-id spam-3.tcl,v 3.2.2.9 2000/09/22 01:34:54 kevin Exp
    @author ported by Jerry Asher (jerry@theashergroup.com)
} { 
    spam_id:notnull
    subject:trim,notnull
    message:trim,notnull
    issue_type:multiple
    amount
    expires
    mailing_list:optional
    user_class_id:optional
    product_id:optional
    start_date:optional
    end_date:optional
    user_id_list:optional,multiple
    viewed_product_id:optional 
    category_id:optional
    show_users_p:optional
}
# 
ad_require_permission [ad_conn package_id] admin

set issue_type_list $issue_type
# no confirm page because they were just sent through the spell
# checker (that's enough submits to push)

set expires_to_insert [ec_decode $expires "" "null" $expires]

# get rid of stupid ^Ms
regsub -all "\r" $message "" message


# doubleclick protection
if { [db_string get_log_entries_cnt "select count(*) from ec_spam_log where spam_id=:spam_id"] > 0 } {
    
    append doc_body "[ad_admin_header "Spam Sent"]
    <h2>Spam Sent</h2>
    [ad_admin_context_bar [list "../index.tcl" "Ecommerce([ec_system_name])"] [list "index.tcl" "Customer Service Administration"] "Spam Sent"]
    <hr>
    You are seeing this page because you probably either hit reload or pushed the Submit button twice.
    <p>
    If you wonder whether the users got the spam, just check the customer service issues for one of the users (all mail sent to a user is recorded as a customer service issue).
    [ad_admin_footer]
    "
    return
}

set return_url "[ad_conn url]?[export_entire_form_as_url_vars]"

set customer_service_rep [ad_get_user_id]

if {$customer_service_rep == 0} {
    ad_returnredirect "/register.tcl?[export_url_vars return_url]"
    return
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
    set users_query "select user_id, email
    from cc_users
    where user_id in ([join $user_id_list ", "])"
  
} elseif { [info exists mailing_list] } {
    if { [llength $mailing_list] == 0 } {
	set search_criteria "(category_id is null and subcategory_id is null and subsubcategory_id is null)"
    } elseif { [llength $mailing_list] == 1 } {
	set search_criteria "(category_id=:mailing_list and subcategory_id is null)"
	set mailing_list_category_id $mailing_list
    } elseif { [llength $mailing_list] == 2 } {
	set search_criteria "(subcategory_id=[lindex $mailing_list 1] and subsubcategory_id is null)"
	set mailing_list_category_id [lindex $mailing_list 0]
	set mailing_list_subcategory_id [lindex $mailing_list 1]
    } else {
	set search_criteria "subsubcategory_id=[lindex $mailing_list 2]"
	set mailing_list_category_id [lindex $mailing_list 0]
	set mailing_list_subcategory_id [lindex $mailing_list 1]
	set mailing_list_subsubcategory_id [lindex $mailing_list 2]
    }

    set users_query "select users.user_id as user_id, email from cc_users, ec_cat_mailing_lists where users.user_id=ec_cat_mailing_lists.user_id and $search_criteria"

} elseif { [info exists user_class_id] } {
    if { ![empty_string_p $user_class_id]} {
	set users_query "select users.user_id as user_id, first_names, last_name, email
	from cc_users, ec_user_class_user_map m
	where m.user_class_id=:user_class_id
	and m.user_id=users.user_id"
    } else {
	set users_query "select user_id, first_names, last_name, email
	from cc_users"
    }
} elseif { [info exists product_id] } {
    set users_query "select unique users.user_id as user_id, first_names, last_name, email
    from cc_users, ec_items, ec_orders
    where ec_items.order_id=ec_orders.order_id
    and ec_orders.user_id=users.user_id
    and ec_items.product_id=:product_id"
} elseif { [info exists viewed_product_id] } {
    set users_query "select unique u.user_id as user_id, first_names, last_name, email
    from cc_users u, ec_user_session_info ui, ec_user_sessions us
    where us.user_session_id=ui.user_session_id
    and us.user_id=u.user_id
    and ui.product_id=:viewed_product_id"
} elseif { [info exists category_id] } {
    set users_query "select unique u.user_id as user_id, first_names, last_name, email
    from cc_users u, ec_user_session_info ui, ec_user_sessions us
    where us.user_session_id=ui.user_session_id
    and us.user_id=u.user_id
    and ui.category_id=:category_id"
} elseif { [info exists start_date] } {
    set users_query "select user_id, first_names, last_name, email
	from cc_users
	where last_visit >= to_date(:start_date,'YYYY-MM-DD HH24:MI:SS') and last_visit <= to_date(:end_date,'YYYY-MM-DD HH24:MI:SS')"
}

# have to make all variables exist that will be inserted into ec_spam_log
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
if { ![info exists start_date] } {
    set start_date ""
}
if { ![info exists end_date] } {
    set end_date ""
}

db_transaction {

    db_dml insert_log_for_spam "
    insert into ec_spam_log
        (spam_id, spam_text, mailing_list_category_id, 
         mailing_list_subcategory_id, mailing_list_subsubcategory_id, 
         user_class_id, product_id, 
         last_visit_start_date, last_visit_end_date)
    values
        (:spam_id, :message, :mailing_list_category_id, 
         :mailing_list_subcategory_id, :mailing_list_subsubcategory_id, 
         :user_class_id, :product_id, 
         to_date(:start_date,'YYYY-MM-DD HH24:MI:SS'), 
         to_date(:end_date,'YYYY-MM-DD HH24:MI:SS'))
    "

set sql $users_query

append doc_body "[ad_admin_header "Spamming Users..."]
<h2>Spamming Users...</h2>

[ad_admin_context_bar [list "../index.tcl" "Ecommerce([ec_system_name])"] [list "index.tcl" "Customer Service Administration"] "Spamming Users..."]

<hr>
<ul>
"

db_foreach get_users_for_spam $sql {
    

    # create a customer service issue/interaction/action
    set user_identification_and_issue_id [ec_customer_service_simple_issue "" "automatic" "email" "To: $email\nFrom: [util_memoize {ad_parameter -package_id [ec_id] CustomerServiceEmailAddress ecommerce} [ec_cache_refresh]]\nSubject: $subject" "" $issue_type_list $message $user_id "" "f"]
    
    set user_identification_id [lindex $user_identification_and_issue_id 0]
    set issue_id [lindex $user_identification_and_issue_id 1]
    
    set email_from [ec_customer_service_email_address $user_identification_id $issue_id]
    
    ec_sendmail_from_service "$email" "$email_from" "$subject" "$message"

    if { ![empty_string_p $amount] && $amount > 0 } {
	# put a record into ec_gift_certificates
	# and add the amount to the user's gift certificate account

	db_dml insert_record_for_gift_certificates "
        insert into ec_gift_certificates
	     (gift_certificate_id, user_id, amount, 
              expires, 
              issue_date, issued_by, gift_certificate_state, 
              last_modified, last_modifying_user, modified_ip_address)
	values
	     (ec_gift_cert_id_sequence.nextval, :user_id, :amount, 
              $expires_to_insert, 
              sysdate, :customer_service_rep, 'authorized', 
              sysdate, :customer_service_rep, '[ns_conn peeraddr]')
	"
    }
    
    append doc_body "<li>Email has been sent to $email\n"
}

}

append doc_body "</ul>

[ad_admin_footer]"




doc_return  200 text/html $doc_body




