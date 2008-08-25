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

set title  "Confirm Delete"
set context [list [list index "Customer Service"] $title]

set response_html [ec_display_as_html $response_text]
