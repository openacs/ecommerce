# /www/[ec_url_concat [ec_url] /admin]/orders/items-add-2.tcl
ad_page_contract {

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id items-add-2.tcl,v 3.2.6.3 2000/08/16 21:19:21 seb Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  order_id:integer,notnull
  product_id:integer,optional
  product_name:optional
}

ad_require_permission [ad_conn package_id] admin

doc_body_append "[ad_admin_header "Add Items, Cont."]

<h2>Add Items, Cont.</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index" "Orders"] [list "one?order_id=$order_id" "One Order"] "Add Items, Cont."]

<hr>
"

if { [exists_and_not_null product_id] } {
    set additional_query_part "product_id=:product_id"
} else {
    set additional_query_part "upper(product_name) like '%' || upper(:product_name) || '%'"
}

set product_counter 0
db_foreach products_select "select product_id, product_name from ec_products where $additional_query_part" {
    if { $product_counter == 0 } {
	doc_body_append "Here are the product(s) that match your search.
	<p>
	Note: the customer's credit card is not going to be reauthorized when you add this item to the order (their card was already found to be valid when they placed the intial order).  They will, as usual, be automatically billed for this item when it ships.  If the customer's credit limit is in question, just make a test authorization offline.
	<ul>
	"
    }
    incr product_counter
#    doc_body_append "<li><a href=\"items-add-3?[export_url_vars order_id product_id]\">$product_name</a>\n"
    doc_body_append "<li><a href=\"[ec_url_concat [ec_url] /admin]/products/one?[export_url_vars product_id]\">$product_name</a>
    <br>
    [ec_add_to_cart_link $product_id "Add to Order" "Add to Order" "items-add-3" $order_id]
    <p>
    "
}

if { $product_counter == 0 } {
    doc_body_append "No matching products were found.\n"
} else {
    doc_body_append "</ul>"
}

doc_body_append "
[ad_admin_footer]
"
