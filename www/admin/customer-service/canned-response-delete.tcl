# canned-response-delete.tcl

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




doc_return  200 text/html "[ad_admin_header "Confirm Delete"]

<h2>Confirm Delete</h2>

<hr>

Are you sure you want to delete this canned response?

<h3>$one_line</h3>
[ec_display_as_html $response_text]

<p>

<center>
<a href=\"canned-response-delete-2?response_id=$response_id\">Yes, get rid of it</a>
</center>

[ad_admin_footer]
"
