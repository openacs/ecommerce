# picklist-value-add.tcl

ad_page_contract {
    @param table_name
    @param col_to_insert
    @param val_to_insert

    @author
    @creation-date
    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    table_name
    col_to_insert
    val_to_insert
}

ad_require_permission [ad_conn package_id] admin

db_dml insert_new_picklist_value "insert into $table_name
($col_to_insert)
values
(:val_to_insert)
"
db_release_unused_handles

ad_returnredirect picklists.tcl