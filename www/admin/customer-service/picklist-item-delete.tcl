# picklist-item-delete.tcl
ad_page_contract {
    @param  picklist_item_id
    @author
    @creation-date
    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    picklist_item_id
}

ad_require_permission [ad_conn package_id] admin

set title  "Please Confirm Deletion"
set context [list [list index "Customer Service"] $title]

set export_form_vars_html [export_form_vars picklist_item_id]
