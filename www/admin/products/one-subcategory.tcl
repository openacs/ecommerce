# one-subcategory.tcl

ad_page_contract { 
    @param category_id
    @param category_name
    @param subcategory_id
    @param subcategory_name

    @author
    @creation-date
    @cvs-id one-subcategory.tcl,v 3.1.6.4 2000/07/21 03:57:02 ron Exp
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    category_id
    category_name
    subcategory_id
    subcategory_name
}

ad_require_permission [ad_conn package_id] admin

doc_body_append "[ad_admin_header "Products in $category_name: $subcategory_name"]

<h2>Products in $category_name: $subcategory_name</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index.tcl" "Products"] "Products in $category_name: $subcategory_name"]

<hr>

<ul>
"



set sql "select m.product_id, p.product_name
from ec_subcategory_product_map m, ec_products p
where m.product_id = p.product_id
and m.subcategory_id=:subcategory_id
order by product_name"

set product_counter 0
db_foreach get_product_infos $sql {
    incr product_counter
    
    doc_body_append "<li><a href=\"one?[export_url_vars product_id]\">$product_name</a>\n"
}

if { $product_counter == 0 } {
    doc_body_append "There are no products in this subcategory.\n"
}

doc_body_append "</ul>

[ad_admin_footer]
"




