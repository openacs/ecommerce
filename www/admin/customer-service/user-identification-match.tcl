# user-identification-match.tcl
ad_page_contract {
    @param  user_identification_id
    @param d_user_id

    @author
    @creation-date
    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    user_identification_id
    d_user_id
}

ad_require_permission [ad_conn package_id] admin

set exception_count 0
set exception_text ""

if { ![info exists d_user_id] || [empty_string_p $d_user_id] } {
    incr exception_count
    append exception_text "<li>You forgot to pick a registered user to match up this unregistered user with.</li>"
}

if { $exception_count > 0 } {
    ad_return_complaint $exception_count $exception_text
    return
}

set title "Confirm Permanent Match"
set context [list [list index "Customer Service"] $title]

set export_form_vars_html [export_form_vars d_user_id user_identification_id]
