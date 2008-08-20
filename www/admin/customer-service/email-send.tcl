# email-send.tcl

ad_page_contract { 
    @param issue_id
    @param user_identification_id

    @author
    @creation-date
    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    issue_id
    user_identification_id

}

ad_require_permission [ad_conn package_id] admin

set return_url "[ad_conn url]?[export_entire_form_as_url_vars]"

set customer_service_rep [ad_get_user_id]

if {$customer_service_rep == 0} {
    ad_returnredirect "/register.tcl?[export_url_vars return_url]"
    ad_script_abort
}

set title  "Send Email to Customer"
set context [list [list index "Customer Service"] $title]

# make sure this user_identification_id has an email address associated with it
db_1row get_user_information "
select u.email as user_email, id.email as id_email
  from cc_users u, ec_user_identification id
 where id.user_id = u.user_id(+)
   and id.user_identification_id=:user_identification_id"

if { ![empty_string_p $user_email] } {
    set email_to_use $user_email
} else {
    set email_to_use $id_email
}

if { [empty_string_p $email_to_use] } {
    set early_message "No email sent. Sorry, we don't have the customer's email address on file."
} else {
   set early_message "If you are not [db_string get_full_name "select first_names || ' ' || last_name from cc_users where user_id=:customer_service_rep"], please <a href=\"/register?[export_url_vars return_url]\">log in</a>"

    # generate action_id here for double-click protection
    set action_id [db_nextval ec_action_id_sequence]

    set export_form_vars_html "[ec_hidden_input var_to_spellcheck "message"]\
        [ec_hidden_input target_url "[ec_url_concat [ec_url] /admin]/customer-service/email-send-2.tcl"]\
        [export_form_vars email_to_use action_id issue_id customer_service_rep user_identification_id]"

    set customer_service_email [parameter::get -package_id [ec_id] -parameter CustomerServiceEmailAddress]
    set email_form_message [ec_canned_response_selector email_form message]
}
