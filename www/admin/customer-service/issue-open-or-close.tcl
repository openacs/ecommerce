# issue-open-or-close.tcl
ad_page_contract {
    @param issue_id
    @param close_p
    @author
    @creation-date
    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    issue_id
    close_p
}
 
ad_require_permission [ad_conn package_id] admin

set return_url "[ad_conn url]?[export_entire_form_as_url_vars]"

set customer_service_rep [ad_get_user_id]
if {$customer_service_rep == 0} {
    ad_returnredirect "/register.tcl?[export_url_vars return_url]"
    ad_script_abort
}

if { $close_p == "t" } {
    set title "Close Issue ${issue_id}"
} else {
    set title "Reopen Issue ${issue_id}"
}
set context [list [list index "Customer Service"] $title]

set confirm_user_html "If you are not [db_string get_user_name "select first_names || ' ' || last_name from cc_users where user_id=:customer_service_rep"], please <a href=\"/register?[export_url_vars return_url]\">log in</a>"

set issue_action "[ec_decode $close_p "t" "close" "reopen"]"

set export_form_vars_html [export_form_vars issue_id close_p customer_service_rep]

