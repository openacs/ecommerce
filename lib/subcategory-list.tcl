# returns a grouping of subcategories within a category
# requires  
# @param category_id
#  optional:
# @param col_width = maximum number of characters per subcategory_name
# @param columns_count = forces code to use that many columns
# or 
# @param max_per_col = forces code to use no more than this many rows in a column

db_1row get_category_name "select category_name from ec_categories where category_id=:category_id"
set subcategory_list [db_list_of_lists get_subcategory_list "select subcategory_name,subcategory_id from ec_subcategories where category_id=:category_id order by upper(subcategory_name)"]
set subcategory_list_count [llength $subcategory_list]
if { ![info exists columns_count] } {
    if { ![info exists max_per_col] } {
        set max_per_col 35
    } 
    set columns_count [expr { floor( $subcategory_list_count / $max_per_col ) + 1 } ]
} else {
    set max_per_col [expr { floor( $subcategory_list_count / $columns_count ) + 1 } ]
}
if { ![info exists col_width] } {
    set col_width 40
} 

set current_row 1
set current_col 1
set category_list_box ""
set subsubcategory_id 0

foreach {subcategory } $subcategory_list {
    set subcategory_name [ecds_abbreviate [lindex $subcategory 0] $col_width]
    set subcategory_id [lindex $subcategory 1]

    append category_list_box "<li><a href=\"[export_var -base "[ec_url]category-browse-subcategory" -override {category_id subcategory_id}]\">${subcategory_name}</a></li>\n"


    if { $current_row >= $max_per_col } {
       set current_row 1
       incr current_col
        append category_list_box "</ul></td><td valign=\"top\"><ul>"
    } else {
        incr current_row
    }
}


