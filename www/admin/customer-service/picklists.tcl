# picklists.tcl
ad_page_contract {
    To add a new picklist, just add an element to picklist_list;
    all UI changes on this page will be taken care of automatically
    @author
    @creation-date
    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
}
 
ad_require_permission [ad_conn package_id] admin

set title  "Picklist Management"
set context [list [list index "Customer Service"] $title]

set picklist_list [list [list issue_type "Issue Type"] [list info_used "Information used to respond to inquiry"] [list interaction_type "Inquired Via"]]

set picklist_counter 0
set picklist_list_html ""
foreach picklist $picklist_list {
    if { $picklist_counter != 0 } {
        append picklist_list_html "</table>\n"
    }
    append picklist_list_html "<h3>[lindex $picklist 1]</h3><table>\n"
    set picklist_name [lindex $picklist 0]
    set sql "select picklist_item_id, picklist_item, picklist_name, sort_key
     from ec_picklist_items
     where picklist_name=:picklist_name
     order by sort_key"
    set picklist_item_counter 0
    set old_picklist_item_id ""
    set old_picklist_sort_key ""
    db_foreach get_picklists $sql {
        incr picklist_item_counter
        if { ![empty_string_p $old_picklist_item_id] } {
            append picklist_list_html "<td> &nbsp; <a href=\"picklist-item-add?prev_sort_key=$old_sort_key&next_sort_key=$sort_key&picklist_name=[ns_urlencode [lindex $picklist 0]]\">insert after</a> &nbsp;&nbsp; <a href=\"picklist-item-swap?picklist_item_id=$old_picklist_item_id&next_picklist_item_id=$picklist_item_id&sort_key=$old_sort_key&next_sort_key=$sort_key\">swap with next</a></td></tr>"
        }
        set old_picklist_item_id $picklist_item_id
        set old_sort_key $sort_key
        append picklist_list_html "<tr><td>$picklist_item_counter. $picklist_item</td><td><a href=\"picklist-item-delete?picklist_item_id=$picklist_item_id\">delete</a></td>"
    }
    if { $picklist_item_counter != 0 } {
        append picklist_list_html "<td> &nbsp; <a href=\"picklist-item-add?prev_sort_key=$old_sort_key&next_sort_key=[expr $old_sort_key + 512]&picklist_name=[ns_urlencode [lindex $picklist 0]]\">insert after</a></td></tr>\n"
    } 
    incr picklist_counter
}
append picklist_list_html "</table>\n"

if { $picklist_counter == 0 } {
    set picklist_list_html "<a href=\"picklist-item-add?prev_sort_key=1&next_sort_key=512&picklist_name=[ns_urlencode [lindex $picklist 0]]\">Add a picklist item.</a>"
}
