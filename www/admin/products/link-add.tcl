#  www/[ec_url_concat [ec_url] /admin]/products/link-add.tcl
ad_page_contract {

  @author
  @creation-date Summer 1999
  @cvs-id link-add.tcl,v 3.1.6.2 2000/07/22 07:57:39 ron Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  product_id:integer,notnull
  link_product_name:optional
  link_product_id:integer,notnull,optional
}

ad_require_permission [ad_conn package_id] admin

set product_name [ec_product_name $product_id]

doc_body_append "[ad_admin_header "Create New Link"]

<h2>Create New Link</h2>

[ad_admin_context_bar [list ../ "Ecommerce([ec_system_name])"] [list "index.tcl" "Products"] [list "one.tcl?[export_url_vars product_id]" $product_name] "New Link"]

<hr>
Please select the product you wish to link to or from:
<ul>
"

if { [info exists link_product_id] } {
    set additional_query_part "product_id=:link_product_id"
} else {
    set additional_query_part "upper(product_name) like '%' || upper(:link_product_name) || '%'"
}


db_foreach product_search_select "select product_id as link_product_id, product_name as link_product_name from ec_products where $additional_query_part" {
    doc_body_append "<li><a href=\"link-add-2?[export_url_vars product_id link_product_id]\">$link_product_name</a>\n"
} if_no_rows {
    doc_body_append "No matching products were found.\n"
}

doc_body_append "</ul>

[ad_admin_footer]
"