# active-toggle.tcl

ad_page_contract { 
    @param table_name
    @param primary_key_name
    @param primary_key_value
    @param active_p
    @author
    @creation-date
    @cvs-id active-toggle.tcl,v 3.1.6.3 2000/07/21 03:56:49 ron Exp
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    table_name
    primary_key_name
    primary_key_value
    active_p

}

ad_require_permission [ad_conn package_id] admin

db_dml update_customer_service_table "update $table_name
set active_p=:active_p
where $primary_key_name=:primary_key_value"
db_release_unused_handles
ad_returnredirect picklists.tcl
