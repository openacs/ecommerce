# canned-response-add-2.tcl

ad_page_contract {
    @param one_line
    @param response_text

    @author
    @creation-date
    @cvs-id canned-response-add-2.tcl,v 3.2.6.4 2000/07/21 03:56:49 ron Exp
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    one_line
    response_text
}

ad_require_permission [ad_conn package_id] admin

set existing_response_id [db_string get_response_id "select response_id from ec_canned_responses where one_line = :one_line" -default ""]

if { ![empty_string_p $existing_response_id] } {
    ad_return_warning "Response Exists" "There already exists a canned response
with this description. You can <a href=\"canned-response-edit?response_id=$existing_response_id\">edit it</a> or go back and try again."
    return
}

db_dml insert_new_canned_response "insert into ec_canned_responses (response_id, one_line, response_text)
values (ec_canned_response_id_sequence.nextval, :one_line, :response_text)"
db_release_unused_handles
ad_returnredirect "canned-responses.tcl"