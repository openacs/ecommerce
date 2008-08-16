#  www/[ec_url_concat [ec_url] /admin]/products/recommendation-add-3.tcl
ad_page_contract {
  Recommend a product.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  product_id:integer,notnull
  user_class_id:integer
  recommendation_text:html
  categorization
}

ad_require_permission [ad_conn package_id] admin

set product_name [ec_product_name $product_id]

# deal w/categorization for display purposes
set category_list [list]
set subcategory_list [list]
set subsubcategory_list [list]
for { set counter 0 } { $counter < [llength $categorization] } {incr counter} {
    if { $counter == 0 } {
        lappend category_list [lindex $categorization 0]
    }
    if { $counter == 1 } {
        lappend subcategory_list [lindex $categorization 1]
    }
    if { $counter == 2 } {
        lappend subsubcategory_list [lindex $categorization 2]
    }
}

set recommendation_id [db_nextval ec_recommendation_id_sequence]

set title "Confirm Product Recommendation"
set context [list [list index Products] $title]

if { ![empty_string_p $user_class_id] } {
    set user_class_html "[db_string user_class_select "select user_class_name from ec_user_classes where user_class_id=:user_class_id"]"
} else {
    set user_class_html "All Users"
}

if { [empty_string_p $categorization] } {
    set categorization_html "Top Level"
} else {
    set categorization_html "[ec_category_subcategory_and_subsubcategory_display $category_list $subcategory_list $subsubcategory_list]"
}

set export_form_vars_html [export_form_vars product_id product_name user_class_id recommendation_text recommendation_id categorization]

