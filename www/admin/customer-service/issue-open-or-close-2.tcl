# issue-open-or-close-2.tcl

ad_page_contract { 
    @param issue_id:naturalnum,notnull
    @param close_p:notnull
    @param customer_service_rep:naturalnum,notnull

    @author
    @creation-date
    @cvs-id issue-open-or-close-2.tcl,v 3.1.6.4 2000/07/21 03:56:57 ron Exp
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    issue_id:naturalnum,notnull
    close_p:notnull
    customer_service_rep:naturalnum,notnull
}
# 
ad_require_permission [ad_conn package_id] admin

if { $close_p == "t" } {
    db_dml update_service_issue "update ec_customer_service_issues set close_date=sysdate, closed_by=:customer_service_rep where issue_id=:issue_id"
} else {
    db_dml update_service_issue_state "update ec_customer_service_issues set close_date=null where issue_id=:issue_id"
}
db_release_unused_handles

ad_returnredirect "issue.tcl?[export_url_vars issue_id]"