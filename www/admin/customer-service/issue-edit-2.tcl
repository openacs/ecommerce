# issue-edit-2.tcl

ad_page_contract { 
    @param issue_id 
    @param issue_type:multiple
    @param {issue_type_list ""}

    @author
    @creation-date
    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    issue_id 
    issue_type:multiple
    {issue_type_list ""}
}

ad_require_permission [ad_conn package_id] admin

# Another hack to make this crap code work. The foreach below loops only over
# the list of issue type already assigned to the issue. Hence, to make this work
# the new list is concatenated to the old list.
set issue_type_list [concat $issue_type_list $issue_type]

db_transaction {
    db_dml delete_from_issue_type_map "delete from ec_cs_issue_type_map where issue_id=:issue_id"
    foreach issue_type $issue_type_list {
	if {$issue_type != "" } {
	    db_dml insert_into_type_map "insert into ec_cs_issue_type_map (issue_id, issue_type) values (:issue_id,:issue_type)"
	}
    }
}
db_release_unused_handles

ad_returnredirect "issue?[export_url_vars issue_id]"