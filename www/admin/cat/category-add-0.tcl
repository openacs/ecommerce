# /www/[ec_url_concat [ec_url] /admin]/cat/category-add-0.tcl
ad_page_contract {
    @param prev_sort_key the previous sort key
    @param next_sort_key the next sort key

    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
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
    ad_return_complaint 1 "<li>The page you came from appears to be out-of-date;
    perhaps someone has changed the categories since you last reloaded the page.
    Please go back to the previous page, push \"reload\" or \"refresh\" and try
    again."
    return
}



append page_html "[ad_admin_header "Add a New Category"]

<h2>Add a New Category</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index.tcl" "Product Categories"] "Add a New Category"]

<hr>

<ul>

<form method=post action=category-add>
[export_form_vars prev_sort_key next_sort_key]
Name: <input type=text name=category_name size=30>
<input type=submit value=\"Add\">
</form>

</ul>

[ad_admin_footer]
"


doc_return  200 text/html $page_html
