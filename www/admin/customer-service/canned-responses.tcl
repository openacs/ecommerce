# canned-responses.tcl

ad_page_contract {
    @author
    @creation-date
    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
}

ad_require_permission [ad_conn package_id] admin

set title  "Prepared Responses"
set context [list [list index "Customer Service"] $title]

set sql "select response_id, one_line, response_text
    from ec_canned_responses order by one_line"

set count 0

set canned_responses_html ""
db_foreach get_canned_responses $sql {
    append canned_responses_html "<li><a href=\"canned-response-edit?response_id=$response_id\">$one_line</a> [ec_display_as_html $response_text] (<a href=\"canned-response-delete?response_id=$response_id\">Delete</a>)</li>"
    incr count
}

