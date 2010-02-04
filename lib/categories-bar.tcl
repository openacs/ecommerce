# requires product_id
# for one product, displays the tree of categories as a list
        
# find all subsubcategories
set subsubcategory_id_list [db_list subsubcategory_id_ordered_list "select subsubcategory_id from ec_subsubcategory_product_map where product_id=:product_id"]
# find all subcategories
set subcategory_id_list [db_list subcategory_id_ordered_list "select subcategory_id from ec_subcategory_product_map where product_id=:product_id"]

# find all categories (ordered)
set category_id_name_list [db_list_of_lists category_id_ordered_list5 "select m.category_id, c.category_name from ec_category_product_map m, ec_categories c where m.category_id = c.category_id and product_id = :product_id order by c.sort_key"]
if { [llength $category_id_name_list] > 0 } {
    set to_return "<h3>Product categories</h3><ul>\n"
    foreach cat_list $category_id_name_list {
        set category_id [lindex $cat_list 0]
        set category_name [lindex $cat_list 1]

        regsub -all -- {&} $category_name {\&amp;} category_name
        set category_name [ec_space_to_nbsp $category_name]
        
        # subcategories within category
        if { [llength $subcategory_id_list] > 0 } {
            set relevant_subcategory_list [db_list_of_lists product_subcategories_of_cat "select subcategory_id, subcategory_name from ec_subcategories 
        where category_id = :category_id and subcategory_id in ([template::util::tcl_to_sql_list $subcategory_id_list]) order by sort_key"]
        } else {
            set relevant_subcategory_list [list]
        }
        if { [llength $relevant_subcategory_list] > 0  } {
            foreach subcat_list $relevant_subcategory_list {
                set subcategory_id [lindex $subcat_list 0]
                set subcategory_name [lindex $subcat_list 1]
                regsub -all -- {&} $subcategory_name {/&amp;} subcategory_name
                set subcategory_name [ec_space_to_nbsp $subcategory_name]
                if { [llength $subsubcategory_id_list] > 0 } {
                    # subsubcategories within subcategory
                    set relevant_subsubcategory_list [db_list_of_lists product_subsubcategories_of_subcat "select subsubcategory_id, subsubcategory_name from ec_subsubcategories 
                where subcategory_id = :subcategory_id and subsubcategory_id in ([template::util::tcl_to_sql_list $subsubcategory_id_list]) order by sort_key"]
                } else {
                    set relevant_subsubcategory_list [list]
                }
                if { [llength $relevant_subsubcategory_list] > 0 } {
                    foreach subsubcat_list $relevant_subcategory_list {
                        set subsubcategory_id [lindex $subsubcat_list 0]
                        set subsubcategory_name [lindex $subsubcat_list 1]
                        regsub -all -- {&} $subsubcategory_name {/&amp;} subsubcategory_name
                        set subsubcategory_name [ec_space_to_nbsp $subsubcategory_name]
                        append to_return "<li><a href=\"[export_vars -base "[ec_url]category-browse" -override {category_id}]\">${category_name}</a> &gt; <a href=\"[export_vars -base "[ec_url]category-browse-subcategory" -override {category_id subcategory_id}]\">${subcategory_name}</a> &gt; ${subsubcategory_name}</li>\n"
                    }
                } else {
                    append to_return "<li><a href=\"[export_vars -base "[ec_url]category-browse" -override {category_id}]\">${category_name}</a> &gt; <a href=\"[export_vars -base "[ec_url]category-browse-subcategory" -override {category_id subcategory_id}]\">${subcategory_name}</a></li>\n"
                }
            }
        } else {
            append to_return "<li><a href=\"[export_vars -base "[ec_url]category-browse" -override {category_id}]\">${category_name}</a></li>\n"
        }
    }
    append to_return "</ul>\n"
} else {
    set to_return ""
}
