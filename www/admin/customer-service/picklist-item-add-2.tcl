# picklist-item-add-2.tcl

ad_page_contract { 
    @param picklist_item_id
    @param picklist_item
    @param picklist_name
    @param prev_sort_key
    @param next_sort_key

    @author
    @creation-date
    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    picklist_item_id
    picklist_item
    picklist_name
    prev_sort_key:notnull
    next_sort_key:notnull
}
# 
ad_require_permission [ad_conn package_id] admin

# we need them to be logged in
set user_id [ad_verify_and_get_user_id]

if {$user_id == 0} {
    
    set return_url "[ad_conn url]?[export_entire_form_as_url_vars]"

    ad_returnredirect "/register?[export_url_vars return_url]"
    return
}

# see first whether they already entered this category (in case they
# pushed submit twice), in which case, just redirect to 
# index.tcl



if { [db_0or1row get_picklist_item_id "select picklist_item_id from ec_picklist_items
where picklist_item_id=:picklist_item_id"] == 1 } {
    ad_returnredirect "picklists"
    return
}

# now make sure that there is no picklist_item with the
# same picklist_name with a sort key equal to the new sort key

set sort_key [expr ($prev_sort_key + $next_sort_key)/2]

set n_conflicts [db_string get_n_conflicts "select count(*)
from ec_picklist_items
where picklist_name=:picklist_name
and sort_key = :sort_key"]

if { $n_conflicts > 0 } {
    ad_return_complaint 1 "<li>The picklist management page you came from appears
    to be out-of-date; perhaps someone has changed the picklist items since you
    last reloaded the page.
    Please go back to <a href=\"picklists\">the picklist management page</a>,
    push \"reload\" or \"refresh\" and try again."
    return
}
set address [ns_conn peeraddr]
db_dml insert_new_picklist_item "insert into ec_picklist_items
(picklist_item_id, picklist_item, picklist_name, sort_key, last_modified, last_modifying_user, modified_ip_address)
values
(:picklist_item_id, :picklist_item, :picklist_name, ($prev_sort_key + $next_sort_key)/2, sysdate, :user_id,:address)"
db_release_unused_handles
ad_returnredirect "picklists"
