# /www/[ec_url_concat [ec_url] /admin]/cat/subcategory-add.tcl

ad_page_contract {

    Confirmation page for adding a new subcategory.

    @param category_id the ID of the category
    @param category_name the name of the category
    @param subcategory_name the name of the new subcategory
    @param prev_sort_key the previous sort key.
    @param next_sort_key the next sort key

    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    category_id:integer,notnull
    category_name:notnull
    subcategory_name:notnull
    prev_sort_key:notnull
    next_sort_key:notnull
}

ad_require_permission [ad_conn package_id] admin

# error checking: make sure that there is no subcategory in this category
# with a sort key equal to the new sort key
# (average of prev_sort_key and next_sort_key);
# otherwise warn them that their form is not up-to-date

### gilbertw - added do the calculation outside of the db.  PostgreSQL encloses
#   the bind variables in ' '
#  where sort_key = (:prev_sort_key + :next_sort_key)/2
set sort_key [expr ($prev_sort_key + $next_sort_key)/2]

set n_conflicts [db_string get_n_conflicts "select count(*)
from ec_subcategories
where category_id=:category_id
and sort_key = :sort_key"]

if { $n_conflicts > 0 } {
    ad_return_complaint 1 "<li>The $category_name page appears to be out-of-date;
    perhaps someone has changed the subcategories since you last reloaded the page.
    Please go back to <a href=\"category?[export_url_vars category_id category_name]\">the $category_name page</a>, push
    \"reload\" or \"refresh\" and try again.</li>"
    return
}

set title "Confirm New Subcategory"
set context [list [list index "Product Categorization"] $title]

set subcategory_id [db_nextval ec_subcategory_id_sequence]

set export_form_vars_html [export_form_vars category_name category_id subcategory_name subcategory_id prev_sort_key next_sort_key]
