# email-send-2.tcl

ad_page_contract { 
    @param action_id
    @param issue_id
    @param customer_service_rep
    @param email_to_use
    @param cc_to
    @param bcc_to
    @param subject
    @param message
    @param user_identification_id
    
    @author
    @creation-date
    @cvs-id email-send-2.tcl,v 3.1.6.3 2000/07/21 03:56:52 ron Exp
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    action_id
    issue_id
    customer_service_rep
    email_to_use
    cc_to
    bcc_to
    subject
    message
    user_identification_id
}

ad_require_permission [ad_conn package_id] admin

# no confirm page because they were just sent through the spell
# checker (that's enough submits to push)

# check for double-click


if { [db_string check_csa_doubleclick "select count(*) from ec_customer_service_actions where action_id=:action_id"] > 0 } {
    ad_returnredirect "issue.tcl?[export_url_vars issue_id]"
    return
}

# 1. create interaction
# 2. create action
# 3. send email

set email_from [ad_parameter -package_id [ec_id] CustomerServiceEmailAddress ecommerce]

set action_details "From: $email_from
To: $email_to_use
"
if { ![empty_string_p $cc_to] } {
    append action_details "Cc: $cc_to
    "
}
if { ![empty_string_p $bcc_to] } {
    append action_details "Bcc: $bcc_to
    "
}

append action_details "Subject: $subject

$message
"

db_transaction {

    set interaction_id [db_nextval ec_interaction_id_sequence]

    db_dml insert_new_cs_interaction "insert into ec_customer_serv_interactions
(interaction_id, customer_service_rep, user_identification_id, interaction_date, interaction_originator, interaction_type)
values
(:interaction_id, :customer_service_rep, :user_identification_id, sysdate, 'rep', 'email')
"

db_dml  insert_new_action_into_actions "insert into ec_customer_service_actions
(action_id, issue_id, interaction_id, action_details)
values
(:action_id, :issue_id, :interaction_id, :action_details)
"

}

set extra_headers [ns_set new]
if { [info exists cc_to] && $cc_to != "" } {
    ns_set put $extra_headers "Cc" "$cc_to"
    ec_sendmail_from_service $email_to_use [ad_parameter -package_id [ec_id] CustomerServiceEmailAddress ecommerce] $subject $message $extra_headers $bcc_to
} else {
    ec_sendmail_from_service $email_to_use [ad_parameter -package_id [ec_id] CustomerServiceEmailAddress ecommerce] $subject $message "" $bcc_to
}
db_release_unused_handles

ad_returnredirect "issue.tcl?issue_id=$issue_id"
