# canned-response-edit-2.tcl

ad_page_contract { 
    @param response_id
    @param one_line
    @param response_text
    @author
    @creation-date
    @cvs-id canned-response-edit-2.tcl,v 3.1.6.3 2000/07/21 03:56:51 ron Exp
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    response_id
    one_line
    response_text

}

ad_require_permission [ad_conn package_id] admin

db_dml update_cs_canned_response "update ec_canned_responses
set one_line = :one_line, response_text = :response_text
where response_id = :response_id"
db_release_unused_handles

ad_returnredirect "canned-responses.tcl"