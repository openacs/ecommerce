# /www/[ec_url_concat [ec_url] /admin]/cat/subsubcategory-add.tcl
ad_page_contract {

    Confirmation page for creatin new ecommerce product subsubcategory.

    @param category_id the category ID
    @param category_name the category name
    @param subcategory_id the subcategory ID
    @param subcategory_name the subcategory name
    @param subsubcategory_name the subsubcategory new name
    @param prev_sort_key the previous sort key
    @param next_sort_key the next sort key

    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    category_id:integer,notnull
    category_name:notnull
    subcategory_id:integer,notnull
    subcategory_name:notnull
    subsubcategory_name:notnull
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
set sort_key [expr (double($prev_sort_key) + $next_sort_key)/2]

set n_conflicts [db_string get_n_conflicts "select count(*)
from ec_subsubcategories
where subcategory_id=:subcategory_id
and sort_key = :sort_key"]

if { $n_conflicts > 0 } {
    ad_return_complaint 1 "<li>The $subcategory_name page appears to be out-of-date;
    perhaps someone has changed the subcategories since you last reloaded the page.
    Please go back to <a href=\"subcategory?[export_url_vars subcategory_id subcategory_name category_id category_name]\">the $subcategory_name page</a>, push
    \"reload\" or \"refresh\" and try again."
    return
}



set page_html "[ad_admin_header "Confirm New Subsubcategory"]

<h2>Confirm New Subsubcategory</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index" "Categories &amp; Subcategories"] "Confirm New Subsubcategory"]

<hr>

Add the following new subsubcategory to $subcategory_name?

<blockquote>
<code>$subsubcategory_name</code>
</blockquote>
"

set subsubcategory_id [db_nextval ec_subsubcategory_id_sequence]

append page_html "<form method=post action=subsubcategory-add-2>
[export_form_vars category_name category_id subcategory_name subcategory_id subsubcategory_name subsubcategory_id prev_sort_key next_sort_key]
<center>
<input type=submit value=\"Yes\">
</center>
</form>

[ad_admin_footer]
"


doc_return  200 text/html $page_html
