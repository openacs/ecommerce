# edit-2.tcl

ad_page_contract {  
    @param email_template_id
    @param variables
    @param title
    @param subject
    @param message
    @param when_sent
    @param issue_type:multiple

    @author
    @creation-date
    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    email_template_id:notnull
    variables
    title:trim,notnull
    subject:notnull
    message:notnull
    when_sent
    issue_type:multiple
}

ad_require_permission [ad_conn package_id] admin

set user_id [ad_verify_and_get_user_id]

if {$user_id == 0} {
    
    set return_url "[ad_conn url]?[export_entire_form_as_url_vars]"

    ad_returnredirect "/register.tcl?[export_url_vars return_url]"
    return
}

set f [ec_adp_function_p $message]
if {$f != 0} {
    ad_return_complaint 1 "
    <P>We're sorry, but templates added here cannot
    have functions in them for security reasons. Only HTML and 
    <%= \$variable %> style code may be used.  We found <tt>$function</tt> in this template"

}


#regsub -all "\r" $QQmessage "" newQQmessage

if { [catch {db_dml update_ec_email_template "
     update ec_email_templates
     set title=:title, 
         subject=:subject, 
         message=:message, 
         variables=:variables, 
         when_sent=:when_sent, 
         issue_type_list=:issue_type, 
         last_modified=sysdate, 
         last_modifying_user=:user_id, 
         modified_ip_address='[DoubleApos [ns_conn peeraddr]]'
     where email_template_id=:email_template_id"} errMsg ]} {
     ad_return_complaint 1 "Failed to update the email template."
}

db_release_unused_handles

ad_returnredirect "index.tcl"
