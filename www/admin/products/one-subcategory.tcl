# one-subcategory.tcl

ad_page_contract { 
    @param category_id
    @param category_name
    @param subcategory_id
    @param subcategory_name

    @author
    @creation-date
    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    category_id
    category_name
    subcategory_id
    subcategory_name
}

ad_require_permission [ad_conn package_id] admin

set title "Products in $category_name: $subcategory_name"
set context [list [list index Products] $title]

set sql "select m.product_id, p.product_name
from ec_subcategory_product_map m, ec_products p
where m.product_id = p.product_id
and m.subcategory_id=:subcategory_id
order by product_name"

set get_product_infos_html ""
set product_counter 0
db_foreach get_product_infos $sql {
    incr product_counter
    append get_product_infos_html "<li><a href=\"one?[export_url_vars product_id]\">$product_name</a></li>\n"
}





