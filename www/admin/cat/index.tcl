ad_page_contract {
    @cvs-id index.tcl,v 3.2.2.4 2000/09/22 01:34:48 kevin Exp
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
}

ad_require_permission [ad_conn package_id] admin

set page_html "[ad_admin_header "Product Category Administration"]

<h2>Product Category Administration</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] "Product Categories"]

<hr>

<h3>Current Categories</h3>

<blockquote>
<table>
"
set old_category_id ""
set old_sort_key ""
set category_counter 0

db_foreach get_categories_loop "select category_id, sort_key, category_name from ec_categories order by sort_key" {

    incr category_counter

    if { ![empty_string_p $old_category_id] } {
	append page_html "<td> &nbsp;&nbsp;<font face=\"MS Sans Serif, arial,helvetica\"  size=1><a href=\"category-add-0?prev_sort_key=$old_sort_key&next_sort_key=$sort_key\">insert after</a> &nbsp;&nbsp; <a href=\"category-swap?category_id=$old_category_id&next_category_id=$category_id&sort_key=$old_sort_key&next_sort_key=$sort_key\">swap with next</a></font></td></tr>"
    }
    set old_category_id $category_id
    set old_sort_key $sort_key
    append page_html "<tr><td>$category_counter. <a href=\"category?[export_url_vars category_id category_name]\">$category_name</a></td>\n"
}

if { $category_counter != 0 } {
    append page_html "<td> &nbsp;&nbsp;<font face=\"MS Sans Serif, arial,helvetica\"  size=1><a href=\"category-add-0?prev_sort_key=$old_sort_key&next_sort_key=[expr $old_sort_key + 2]\">insert after</a></font></td></tr>
    "
} else {
    append page_html "You haven't set up any categories.  <a href=\"category-add-0?prev_sort_key=1&next_sort_key=2\">Add a category.</a>\n"
}

append page_html "
</table>
</blockquote>

[ad_admin_footer]
"


doc_return  200 text/html $page_html

