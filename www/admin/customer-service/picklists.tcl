# picklists.tcl

ad_page_contract {
    To add a new picklist, just add an element to picklist_list;
    all UI changes on this page will be taken care of automatically
    @author
    @creation-date
    @cvs-id picklists.tcl,v 3.1.6.4 2000/09/22 01:34:54 kevin Exp
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
}
# 
ad_require_permission [ad_conn package_id] admin

append doc_body "[ad_admin_header "Picklist Management"]
<h2>Picklist Management</h2>

[ad_admin_context_bar [list "../index.tcl" "Ecommerce([ec_system_name])"] [list "index.tcl" "Customer Service Administration"] "Picklist Management"]

<hr>
These items will appear in the pull-down menus for customer service data entry.
These also determine which items are singled out in reports (items not in these
lists will be grouped together under \"all others\").

<blockquote>
"



set picklist_list [list [list issue_type "Issue Type"] [list info_used "Information used to respond to inquiry"] [list interaction_type "Inquired Via"]]

set picklist_counter 0
foreach picklist $picklist_list {
    if { $picklist_counter != 0 } {
	append doc_body "</table>
	</blockquote>
	"
    }
    append doc_body "<h3>[lindex $picklist 1]</h3>
    <blockquote>
    <table>
    "
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
	    append doc_body "<td> &nbsp;&nbsp;<font face=\"MS Sans Serif, arial,helvetica\"  size=1><a href=\"picklist-item-add?prev_sort_key=$old_sort_key&next_sort_key=$sort_key&picklist_name=[ns_urlencode [lindex $picklist 0]]\">insert after</a> &nbsp;&nbsp; <a href=\"picklist-item-swap?picklist_item_id=$old_picklist_item_id&next_picklist_item_id=$picklist_item_id&sort_key=$old_sort_key&next_sort_key=$sort_key\">swap with next</a></font></td></tr>"
	}
	set old_picklist_item_id $picklist_item_id
	set old_sort_key $sort_key
	append doc_body "<tr><td>$picklist_item_counter. $picklist_item</td>
	<td><font face=\"MS Sans Serif, arial,helvetica\"  size=1><a href=\"picklist-item-delete?picklist_item_id=$picklist_item_id\">delete</a></font></td>\n"

    }
    
    if { $picklist_item_counter != 0 } {
	append doc_body "<td> &nbsp;&nbsp;<font face=\"MS Sans Serif, arial,helvetica\"  size=1><a href=\"picklist-item-add?prev_sort_key=$old_sort_key&next_sort_key=[expr $old_sort_key + 2]&picklist_name=[ns_urlencode [lindex $picklist 0]]\">insert after</a></font></td></tr>
	"
    } else {
	append doc_body "You haven't added any items.  <a href=\"picklist-item-add?prev_sort_key=1&next_sort_key=2&picklist_name=[ns_urlencode [lindex $picklist 0]]\">Add a picklist item.</a>\n"
    }

    incr picklist_counter
}

if { $picklist_counter != 0 } {
    append doc_body "</table>
    </blockquote>
    "
}

append doc_body "</blockquote>
[ad_admin_footer]
"


doc_return  200 text/html $doc_body
