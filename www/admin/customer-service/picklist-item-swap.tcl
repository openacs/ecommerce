# picklist-item-swap.tcl

ad_page_contract {
    @param picklist_item_id
    @param next_picklist_item_id
    @param sort_key
    @param next_sort_key

    @author
    @creation-date
    @cvs-id picklist-item-swap.tcl,v 3.1.6.3 2000/07/21 03:56:58 ron Exp
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    picklist_item_id
    next_picklist_item_id
    sort_key
    next_sort_key
}
#
ad_require_permission [ad_conn package_id] admin

# check that the sort keys are the same as before; otherwise the page
# they got here from is out of date

set item_match [db_string get_item_match "select count(*) from ec_picklist_items where picklist_item_id=:picklist_item_id and sort_key=:sort_key"]

set next_item_match [db_string get_next_item_match "select count(*) from ec_picklist_items where picklist_item_id=:next_picklist_item_id and sort_key=:next_sort_key"]

if { $item_match != 1 || $next_item_match != 1 } {
    ad_return_complaint 1 "<li>The page you came from appears to be out-of-date;
    perhaps someone has changed the picklist items since you last reloaded the page.
    Please go back to the previous page, push \"reload\" or \"refresh\" and try
    again."
    return
}

db_transaction {
db_dml update_current_item "update ec_picklist_items set sort_key=:next_sort_key where picklist_item_id=:picklist_item_id"
db_dml update_next_item "update ec_picklist_items set sort_key=:sort_key where picklist_item_id=:next_picklist_item_id"
}
db_release_unused_handles

ad_returnredirect "picklists.tcl"