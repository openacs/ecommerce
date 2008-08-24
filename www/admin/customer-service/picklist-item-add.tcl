# picklist-item-add.tcl
ad_page_contract {  
    @param picklist_name
    @param prev_sort_key
    @param next_sort_key

    @author
    @creation-date
    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    picklist_name
    prev_sort_key:notnull
    next_sort_key:notnull
}

ad_require_permission [ad_conn package_id] admin

# error checking: make sure that there is no picklist_item with the
# same picklist_name with a sort key equal to the new sort key
# (average of prev_sort_key and next_sort_key);
# otherwise warn them that their form is not up-to-date

set sort_key [expr ($prev_sort_key + $next_sort_key)/2]

set n_conflicts [db_string get_count_items "select count(*)
from ec_picklist_items
where picklist_name=:picklist_name
and sort_key = :sort_key"]

if { $n_conflicts > 0 } {
    ad_return_complaint 1 "<li>The page you came from appears to be out-of-date;
    perhaps someone has changed the picklist items since you last reloaded the page.
    Please go back to the previous page, \"reload\" or \"refresh\" the page and try
    again.</li>"
    return
}

set title "Add an Item"
set context [list [list index "Customer Service"] $title]

set picklist_item_id [db_nextval ec_picklist_item_id_sequence]

set export_form_vars_html "[export_form_vars prev_sort_key next_sort_key picklist_name picklist_item_id]"
