# issue-edit-2.tcl

ad_page_contract { 
    @param issue_id 
    @param issue_type:multiple
    @param {issue_type_list ""}

    @author
    @creation-date
    @cvs-id issue-edit-2.tcl,v 3.2.2.4 2000/07/21 07:05:31 ryanlee Exp
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    issue_id 
    issue_type:multiple
    {issue_type_list ""}
}

ad_require_permission [ad_conn package_id] admin

db_transaction {

db_dml delete_from_issue_type_map "delete from ec_cs_issue_type_map where issue_id=:issue_id"

foreach issue_type $issue_type_list {
    db_dml insert_into_type_map "insert into ec_cs_issue_type_map (issue_id, issue_type) values (:issue_id,:issue_type)"
}

}

db_release_unused_handles

ad_returnredirect "issue?[export_url_vars issue_id]"