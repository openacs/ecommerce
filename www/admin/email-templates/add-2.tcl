# add-2.tcl

ad_page_contract {
    @author
    @creation-date
    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    variables:optional
    title:trim,notnull
    subject:notnull
    message:notnull
    when_sent
    issue_type:multiple
}
# 
ad_require_permission [ad_conn package_id] admin

# 

# we need them to be logged in
set user_id [ad_conn user_id]

if {$user_id == 0} {
    
    set return_url "[ad_conn url]?[export_entire_form_as_url_vars]"

    ad_returnredirect "/register.tcl?[export_url_vars return_url]"
    ad_script_abort
}

# check the entered ADP for functions
set f [ec_adp_function_p $message]
if {$f != 0} {
    ad_return_complaint 1 "
    <P>We're sorry, but templates added here cannot
    have functions in them for security reasons. Only HTML and 
    <%= \$variable %> style code may be used.  We found <tt>$function</tt> in this template"
    ad_script_abort
}




#regsub -all "\r" $QQmessage "" newQQmessage

if { [catch {db_dml unused "insert into ec_email_templates
(email_template_id, title, subject, message, variables, when_sent, issue_type_list, last_modified, last_modifying_user, modified_ip_address)
values
(ec_email_template_id_sequence.nextval, :title, :subject, :message, :variables, :when_sent, :issue_type, sysdate, :user_id, '[DoubleApos [ns_conn peeraddr]]')"} errMsg] } {
    ad_return_complaint 1 "Failed to add the email template, Suspect double click/ template already created"
    ad_script_abort
}

db_release_unused_handles

ad_returnredirect "index.tcl"


