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

doc_body_append "[ad_admin_header "Products in $category_name: $subcategory_name: $subsubcategory_name"]

<h2>Products in $category_name: $subcategory_name: $subsubcategory_name</h2>

[ad_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index.tcl" "Products"] "Products in $category_name: $subcategory_name: $subsubcategory_name"]

<hr>

<ul>
"

set sql "select m.product_id, p.product_name, publisher_favorite_p
from ec_subsubcategory_product_map m, ec_products p
where m.product_id = p.product_id
and m.subsubcategory_id= :subsubcategory_id
order by product_name"

db_foreach select_subsubcate $sql {

    doc_body_append "<li><a href=\"one?[export_url_vars product_id]\">$product_name</a> "
    if { $publisher_favorite_p == "t" } {
	doc_body_append "This is a favorite. "
    }
    if { $publisher_favorite_p == "t" } {
	doc_body_append " \[<a href=\"subsubcategory-property-toggle?publisher_favorite_p=f&[export_url_vars product_id category_id category_name subcategory_id subcategory_name subsubcategory_id subsubcategory_name]\">make it not be a favorite</a>\]"
    } else {
	doc_body_append "\[<a href=\"subsubcategory-property-toggle?publisher_favorite_p=t&[export_url_vars product_id category_id category_name subcategory_id subcategory_name subsubcategory_id subsubcategory_name]\">make this a favorite</a>\]"
    }
    
} if_no_rows {
    
    doc_body_append "There are no products in this subsubcategory.\n"
}

doc_body_append "</ul>

[ad_admin_footer]
"
