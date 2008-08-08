#     Display the ecommerce toolbar containing a product search widget

#     @param category_id
#     @param subcategory_id
#     @param search_text
#     @current_location

# Create empty values for each optional parameter that has not been passed from a master template.
foreach parameter {combocategory_id category_id subcategory_id search_text current_location} {
    if {![info exists $parameter]} {
	set $parameter {}
    }
}

# we'll show a search widget at the top if there are categories to search in
if { ![empty_string_p [db_string get_check_of_categories2 "select 1 from dual where exists (select 1 from ec_categories)" -default ""]] } {
    # Create a context aware search widget to search for products.

    # Decode the combo of category and subcategory ids
    if { ![empty_string_p $combocategory_id] } {
        set category_id [lindex [split $combocategory_id "|"] 0]
        set subcategory_id [lindex [split $combocategory_id "|"] 1]
    }
    set ec_search_widget_fragment [ec_search_widget "$category_id|$subcategory_id"  $search_text]
} else {
    set ec_search_widget_fragment ""
}



