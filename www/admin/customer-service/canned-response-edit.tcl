# canned-response-edit.tcl

ad_page_contract {
    @param response_id
    @author
    @creation-date
    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    response_id
}

ad_require_permission [ad_conn package_id] admin

db_1row get_response_info "select one_line, response_text
from ec_canned_responses
where response_id = :response_id"




doc_return  200 text/html "[ad_admin_header "Edit Canned Response"]
<h2>Edit Canned Response</h2>

[ad_context_bar [list "../index.tcl" "Ecommerce([ec_system_name])"] [list "index.tcl" "Customer Service Administration"] [list "canned-responses.tcl" "Canned Responses"] "Edit Canned Response"]

<hr>

<form action=canned-response-edit-2 method=POST>
[export_form_vars response_id]
<table noborder>
<tr><th>Description</th><td><input type=text size=60 name=one_line value=\"[ad_quotehtml $one_line]\"></tr>
<tr><th>Text</th><td><textarea name=response_text rows=5 cols=70 wrap=soft>$response_text</textarea></tr>
<tr><td align=center colspan=2><input type=submit value=Submit></tr>
</table>
</form>

[ad_admin_footer]
"






