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
    append exception_text "<li>You forgot to pick a registered user to match up this unregistered user with."
}

if { $exception_count > 0 } {
    ad_return_complaint $exception_count $exception_text
    return
}


set page_title "Confirm Match"
append doc_body "[ad_admin_header $page_title]
<h2>$page_title</h2>

[ad_admin_context_bar [list "../index.tcl" "Ecommerce([ec_system_name])"] [list "index.tcl" "Customer Service Administration"] $page_title]

<hr>

Please confirm that you want to make this match.  This cannot be undone.
<center>
<form method=post action=user-identification-match-2>
[export_form_vars d_user_id user_identification_id]
<input type=submit value=\"Confirm\">
</form>
</center>
[ad_admin_footer]
"

doc_return  200 text/html $doc_body
