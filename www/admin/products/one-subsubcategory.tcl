# one-subsubcategory.tcl
# one-subsubcategory.tcl,v 3.1.6.4 2000/08/28 20:19:12 hbrock Exp

ad_page_contract { 
    @param category_id
    @param category_name
    @param subcategory_id
    @param subcategory_name
    @subsubcategory_id 
    @subsubcategory_name

    @author
    @creation-date
    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    category_id
    category_name
    subcategory_id
    subcategory_name
    subsubcategory_id 
    subsubcategory_name
}

ad_require_permission [ad_conn package_id] admin

set title "Products in $category_name: $subcategory_name: $subsubcategory_name"
set context [list [list index Products] $title]

set sql "select m.product_id, p.product_name, publisher_favorite_p
from ec_subsubcategory_product_map m, ec_products p
where m.product_id = p.product_id
and m.subsubcategory_id= :subsubcategory_id
order by product_name"

set select_subsubcate_html ""
db_foreach select_subsubcate $sql {
    set has_rows 1
    append select_subsubcate_html "<li><a href=\"one?[export_url_vars product_id]\">$product_name</a> "
    if { $publisher_favorite_p == "t" } {
        append select_subsubcate_html "This is a favorite. \[<a href=\"subsubcategory-property-toggle?publisher_favorite_p=f&[export_url_vars product_id category_id category_name subcategory_id subcategory_name subsubcategory_id subsubcategory_name]\">make it not be a favorite</a>\]</li>"
    } else {
        append select_subsubcate_html "\[<a href=\"subsubcategory-property-toggle?publisher_favorite_p=t&[export_url_vars product_id category_id category_name subcategory_id subcategory_name subsubcategory_id subsubcategory_name]\">make this a favorite</a>\]</li>"
    }    
} if_no_rows {
    set has_rows 0
}
