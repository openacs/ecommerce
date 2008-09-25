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

set title "Category: ${category_name}"
set context [list [list index "Product Categorization"] $title]

set export_form_vars_html [export_form_vars category_id]
set export_url_vars_cat_id [export_url_vars category_id]
set export_url_vars_cat_id_name [export_url_vars category_id category_name] 

# Set audit variables
# audit_name, audit_id, audit_id_column, return_url, audit_tables, main_tables
set audit_name "$category_name"
set audit_id $category_id
set audit_id_column "category_id"
set return_url "category?[export_url_vars category_id category_name]"
set audit_tables [list ec_categories_audit ec_subcategories_audit ec_category_product_map_audit]
set main_tables [list ec_categories ec_subcategories ec_category_product_map]

set audit_url_html "[ec_url_concat [ec_url] /admin]/audit?[export_url_vars audit_name audit_id audit_id_column return_url audit_tables main_tables]"

set old_subcategory_id 0
set old_sort_key 0
set subcategory_counter 0
set subcat_info_loop_html ""
db_foreach get_subcat_info_loop "select subcategory_id, sort_key, subcategory_name from ec_subcategories where category_id=:category_id order by sort_key" {

    incr subcategory_counter
    if { $old_subcategory_id > 0 } {  
        append subcat_info_loop_html "<td> <a href=\"subcategory-add-0?[export_url_vars category_id category_name]&prev_sort_key=$old_sort_key&next_sort_key=$sort_key\">insert after</a> </td><td> <a href=\"subcategory-swap?[export_url_vars category_id category_name]&subcategory_id=$old_subcategory_id&next_subcategory_id=$subcategory_id&sort_key=$old_sort_key&next_sort_key=$sort_key\">swap with next</a> </td></tr>\n"  
    } 
    set old_subcategory_id $subcategory_id
    set old_sort_key $sort_key
    append subcat_info_loop_html "<tr><td> <a href=\"subcategory?[export_url_vars category_id category_name subcategory_id subcategory_name]\">$subcategory_name</a> </td>"
}
set sort_key [expr { $old_sort_key + round( $old_sort_key * 3 / ( $subcategory_counter + 1.)  ) } ]
append subcat_info_loop_html "<td> <a href=\"subcategory-add-0?[export_url_vars category_id category_name]&prev_sort_key=$old_sort_key&next_sort_key=$sort_key\">insert after</a> </td><td> &nbsp; </td></tr>\n"

set subcat_add_html " <a href=\"subcategory-add-0?[export_url_vars category_id category_name]&prev_sort_key=1&next_sort_key=2\">Add a subcategory</a>."


