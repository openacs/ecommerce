ad_page_contract {
    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
}

ad_require_permission [ad_conn package_id] admin

set title "Product Categorization"
set context [list $title]

set old_category_id ""
set old_sort_key ""
set category_counter 0
set categories_loop_html ""
db_foreach get_categories_loop "select category_id, sort_key, category_name from ec_categories order by sort_key" {

    incr category_counter
    if { ![empty_string_p $old_category_id] } {
        append categories_loop_html "<td> ( <a href=\"category-add-0?prev_sort_key=$old_sort_key&next_sort_key=$sort_key\">insert after</a> | <a href=\"category-swap?category_id=$old_category_id&next_category_id=$category_id&sort_key=$old_sort_key&next_sort_key=$sort_key\">swap with next</a> )</td></tr>\n"
    } 
    set old_category_id $category_id
    set old_sort_key $sort_key
    append categories_loop_html "<tr><td>$category_counter. <a href=\"category?[export_url_vars category_id category_name]\">$category_name</a></td>"
}

if { $category_counter > 0 } {
    append categories_loop_html "<td> ( <a href=\"category-add-0?prev_sort_key=$old_sort_key&next_sort_key=[expr $old_sort_key + 2]\">insert after</a> ) </td></tr>\n"
} 

