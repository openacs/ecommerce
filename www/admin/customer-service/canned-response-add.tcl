# canned-response-add.tcl

ad_page_contract {
    @author
    @creation-date
    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
}

ad_require_permission [ad_conn package_id] admin

doc_return  200 text/html "[ad_admin_header "New Canned Response"]
<h2>New Canned Response</h2>

[ad_admin_context_bar [list "../index.tcl" "Ecommerce([ec_system_name])"] [list "index.tcl" "Customer Service Administration"] [list "canned-responses.tcl" "Canned Responses"] "New Canned Response"]

<hr>

<form action=canned-response-add-2 method=POST>
<table noborder>
<tr><th>Description</th><td><input type=text size=60 name=one_line></tr>
<tr><th>Text</th><td><textarea name=response_text rows=5 cols=70 wrap=soft></textarea></tr>
<tr><td align=center colspan=2><input type=submit value=Submit></tr>
</table>
</form>

[ad_admin_footer]
"
