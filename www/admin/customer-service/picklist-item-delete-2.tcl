# picklist-item-delete-2.tcl

ad_page_contract {
    @param picklist_item_id
    @author
    @creation-date
    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    picklist_item_id
}

ad_require_permission [ad_conn package_id] admin

db_dml delete_item_from_picklist "delete from ec_picklist_items where picklist_item_id=:picklist_item_id"
db_release_unused_handles
ad_returnredirect "picklists.tcl"

