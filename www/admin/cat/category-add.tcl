# /www/[ec_url_concat [ec_url] /admin]/cat/category-add.tcl
ad_page_contract {
    @param category_name the name of the category
    @param next_sort_key the next sort key
    @param prev_sort_key the previous sort key

    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    category_name:trim,notnull
    prev_sort_key:notnull
    next_sort_key:notnull
}

ad_require_permission [ad_conn package_id] admin

# error checking: make sure that there is no category with a sort key
# equal to the new sort key (average of prev_sort_key and next_sort_key);
# otherwise warn them that their form is not up-to-date

### gilbertw - added do the calculation outside of the db.  PostgreSQL encloses
#   the bind variables in ' '
#  where sort_key = (:prev_sort_key + :next_sort_key)/2
set sort_key [expr (double($prev_sort_key) + $next_sort_key)/2]

set n_conflicts [db_string get_n_conflicts "select count(*)
from ec_categories
where sort_key = :sort_key"]

if { $n_conflicts > 0 } {
    ad_return_complaint 1 "<li>The category page appears to be out-of-date;
    perhaps someone has changed the categories since you last reloaded the page.
    Please go back to <a href=\"index\">the category page</a>, push
    \"reload\" or \"refresh\" and try again."
    return
}


set page_html "[ad_admin_header "Confirm New Category"]

<h2>Confirm New Category</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index" "Categories &amp; Subcategories"] "Confirm New Category"]

<hr>

Add the following new category?

<blockquote>
<code>$category_name</code>
</blockquote>
"

set category_id [db_nextval ec_category_id_sequence]

append page_html "<form method=post action=category-add-2>
[export_form_vars category_name category_id prev_sort_key next_sort_key]
<center>
<input type=submit value=\"Yes\">
</center>
</form>

[ad_admin_footer]
"
doc_return  200 text/html $page_html


