# /www/[ec_url_concat [ec_url] /admin]/cat/category.tcl

ad_page_contract {

    Displays properties of one ec category.

    @param category_id the ID for the category
    @param category_name the name for the category

    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {

    category_id:integer,notnull
    category_name:notnull
}

ad_require_permission [ad_conn package_id] admin

set page_html "[ad_admin_header "Category: $category_name"]

<h2>Category: $category_name</h2>

[ad_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index" "Categories &amp; Subcategories"] "One Category"]

<hr>

<ul>

<form method=post action=category-edit>
[export_form_vars category_id]
<li>Change category name to:
<input type=text name=category_name size=30 value=\"[ad_quotehtml $category_name]\">
<input type=submit value=\"Change\">
</form>

<p>

<li><a href=\"../products/list?[export_url_vars category_id]\">View all products in this category</a>

<p>

<li><a href=\"category-delete?[export_url_vars category_id category_name]\">Delete this category</a>

<p>
"

# Set audit variables
# audit_name, audit_id, audit_id_column, return_url, audit_tables, main_tables
set audit_name "$category_name"
set audit_id $category_id
set audit_id_column "category_id"
set return_url "category?[export_url_vars category_id category_name]"
set audit_tables [list ec_categories_audit ec_subcategories_audit ec_category_product_map_audit]
set main_tables [list ec_categories ec_subcategories ec_category_product_map]

append page_html "<li><a href=\"[ec_url_concat [ec_url] /admin]/audit?[export_url_vars audit_name audit_id audit_id_column return_url audit_tables main_tables]\">Audit Trail</a>

</ul>

<p>

<h3>Current Subcategories of $category_name</h3>

<blockquote>
<table>
"
set old_subcategory_id ""
set old_sort_key ""
set subcategory_counter 0



db_foreach get_subcat_info_loop "select subcategory_id, sort_key, subcategory_name from ec_subcategories where category_id=:category_id order by sort_key" {


    incr subcategory_counter

    if { ![empty_string_p $old_subcategory_id] } {
	append page_html "<td> &nbsp;&nbsp;<font face=\"MS Sans Serif, arial,helvetica\"  size=1><a href=\"subcategory-add-0?[export_url_vars category_id category_name]&prev_sort_key=$old_sort_key&next_sort_key=$sort_key\">insert after</a> &nbsp;&nbsp; <a href=\"subcategory-swap?[export_url_vars category_id category_name]&subcategory_id=$old_subcategory_id&next_subcategory_id=$subcategory_id&sort_key=$old_sort_key&next_sort_key=$sort_key\">swap with next</a></font></td></tr>"
    }
    set old_subcategory_id $subcategory_id
    set old_sort_key $sort_key
    append page_html "<tr><td>$subcategory_counter. <a href=\"subcategory?[export_url_vars category_id category_name subcategory_id subcategory_name]\">$subcategory_name</a></td>\n"
}

if { $subcategory_counter != 0 } {
    append page_html "<td> &nbsp;&nbsp;<font face=\"MS Sans Serif, arial,helvetica\"  size=1><a href=\"subcategory-add-0?[export_url_vars category_id category_name]&prev_sort_key=$old_sort_key&next_sort_key=[expr $old_sort_key + 2]\">insert after</a></font></td></tr>
    "
} else {
    append page_html "You haven't set up any subcategories.  <a href=\"subcategory-add-0?[export_url_vars category_id category_name]&prev_sort_key=1&next_sort_key=2\">Add a subcategory.</a>\n"
}

append page_html "
</table>
</blockquote>

[ad_admin_footer]
"


doc_return  200 text/html $page_html


