# canned-responses.tcl

ad_page_contract {
    @author
    @creation-date
    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
}

ad_require_permission [ad_conn package_id] admin

append doc_body "[ad_admin_header "Canned Responses"]
<h2>Canned Responses</h2>

[ad_admin_context_bar [list "../index.tcl" "Ecommerce([ec_system_name])"] [list "index.tcl" "Customer Service Administration"] "Canned Responses"]

<hr>

<h3>Defined Responses</h3>
<ul>
"

set sql "select response_id, one_line, response_text
from ec_canned_responses
order by one_line"

set count 0

db_foreach get_canned_responses $sql {
    

    append doc_body "<li><a href=\"canned-response-edit?response_id=$response_id\">$one_line</a>
<blockquote>
[ec_display_as_html $response_text] <a href=\"canned-response-delete?response_id=$response_id\">Delete</a>
</blockquote>
"

    incr count
}

if { $count == 0 } {
    append doc_body "<li>No defined canned responses.\n"
}

append doc_body "<p>
<a href=\"canned-response-add\">Add a new canned response</a>
</ul>

[ad_admin_footer]
"



doc_return  200 text/html $doc_body
