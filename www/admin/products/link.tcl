ad_page_contract {

    Lets admin maintain links among products (e.g., "you should also
    think about buying X if you're buying Y")

    @author Eve Andersson (eveander@arsdigita.com) 
    @creation-date June 1999
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @revision-date April 2002

} {
    product_id
}

ad_require_permission [ad_conn package_id] admin

set product_name [ec_product_name $product_id]

set title "Links between $product_name and other products"
set context [list [list index Products] $title]


set product_counter_a2 0
set doc_body_a2 ""
db_foreach linked_products_select "
    select product_b, product_name as product_b_name
    from ec_product_links, ec_products
    where product_a=:product_id
    and product_b=ec_products.product_id" {
 
   incr product_counter_a2
    append doc_body_a2 "
	<li><a href=\"one?product_id=$product_b\">$product_b_name</a>
	  \[<a href=\"link-delete?[export_url_vars product_id]&product_a=$product_id&product_b=$product_b\">delete link</a>\]</li>"
}


set product_counter_2a 0
set doc_body_2a ""
db_foreach more_links_select "
    select product_a, product_name as product_a_name
    from ec_product_links, ec_products
    where product_b=:product_id
    and ec_product_links.product_a=ec_products.product_id" {

    incr product_counter_2a
    append doc_body_2a "
	<li><a href=\"one?product_id=$product_a\">$product_a_name</a> 
	  \[<a href=\"link-delete?[export_url_vars product_id]&product_a=$product_a&product_b=$product_id\">delete link</a>\]</li>"
}

set export_product_id_html [export_form_vars product_id]

# Set audit variables audit_name, audit_id, audit_id_column,
# return_url, audit_tables, main_tables

set audit_name "Links from $product_name"
set audit_id $product_id
set audit_id_column "product_a"
set return_url "[ad_conn url]?[export_url_vars product_id]"
set audit_tables [list ec_product_links_audit]
set main_tables [list ec_product_links]
set audit_url_html "[ec_url_concat [ec_url] /admin]/audit?[export_url_vars audit_name audit_id audit_id_column return_url audit_tables main_tables]"

set audit_name "Links to $product_name"
set audit_id_column "product_b"

