# issue-edit.tcl

ad_page_contract {
    @param issue_id

    @author
    @creation-date
    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    issue_id
}
# 
ad_require_permission [ad_conn package_id] admin

set return_url "[ad_conn url]?[export_entire_form_as_url_vars]"

set customer_service_rep [ad_get_user_id]

if {$customer_service_rep == 0} {
    ad_returnredirect "/register.tcl?[export_url_vars return_url]"
    return
}

set page_title "Edit Issue #$issue_id"
append doc_body "[ad_admin_header $page_title]
<h2>$page_title</h2>

[ad_admin_context_bar [list "../index.tcl" "Ecommerce([ec_system_name])"] [list "index.tcl" "Customer Service Administration"] $page_title]

<hr>
"

set issue_type_list [db_list get_issue_types "select issue_type from ec_cs_issue_type_map where issue_id=:issue_id"]

append doc_body "
If you are not [db_string get_user_name "select first_names || ' ' || last_name from cc_users where user_id=:customer_service_rep"], please <a href=\"/register?[export_url_vars return_url]\">log in</a>

<p>

<form method=post action=issue-edit-2>
[export_form_vars issue_id]

Modify Issue Type:
<blockquote>
[ec_issue_type_widget $issue_type_list]
</blockquote>

<p>

<center>
<input type=submit value=\"Submit Changes\">
</center>

</form>

[ad_admin_footer]
"

doc_return  200 text/html  $doc_body
