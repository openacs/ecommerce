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

doc_body_append "
    [ad_admin_header "Links between $product_name and other products"]

    <h2>Links</h2>

    [ad_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index.tcl" "Products"] [list "one.tcl?[export_url_vars product_id]" "One"] "Links"]

    <hr>

    <p>Links <b>from</b> the page for $product_name to other products' display pages:</p>
    <ul>"

set product_counter 0

db_foreach linked_products_select "
    select product_b, product_name as product_b_name
    from ec_product_links, ec_products
    where product_a=:product_id
    and product_b=ec_products.product_id" {
 
   incr product_counter
    doc_body_append "
	<li>
	  <a href=\"one?product_id=$product_b\">$product_b_name</a>
	  \[<a href=\"link-delete?[export_url_vars product_id]&product_a=$product_id&product_b=$product_b\">delete link</a>\]
	</li>"
}

if { $product_counter == 0 } {
    doc_body_append "None"
}

doc_body_append "
    </ul>
    <p>Links <b>to</b> $product_name from other products' display pages:</p>
    <ul>"

set product_counter 0

db_foreach more_links_select "
    select product_a, product_name as product_a_name
    from ec_product_links, ec_products
    where product_b=:product_id
    and ec_product_links.product_a=ec_products.product_id" {

    incr product_counter
    doc_body_append "
	<li>
	  <a href=\"one?product_id=$product_a\">$product_a_name</a> 
	  \[<a href=\"link-delete?[export_url_vars product_id]&product_a=$product_a&product_b=$product_id\">delete link</a>\]
	</li>"
}

if { $product_counter == 0 } {
    doc_body_append "None\n"
}

doc_body_append "
    </ul>
    <p>Search for a product to add a link to/from:</p>
    <blockquote>
      <form method=post action=link-add>
        [export_form_vars product_id]
        Name: <input type=text name=link_product_name size=20> <input type=submit value=\"Search\">
     </form>
     <form method=post action=link-add>
       [export_form_vars product_id]
       SKU: <input type=text name=link_product_sku size=10>
       <input type=submit value=\"Search\">
     </form>
    </blockquote>"

# Set audit variables audit_name, audit_id, audit_id_column,
# return_url, audit_tables, main_tables

set audit_name "Links from $product_name"
set audit_id $product_id
set audit_id_column "product_a"
set return_url "[ad_conn url]?[export_url_vars product_id]"
set audit_tables [list ec_product_links_audit]
set main_tables [list ec_product_links]

doc_body_append "
    <h3>Audit Trail</h3>
    <ul>
      <li>
	<a href=\"[ec_url_concat [ec_url] /admin]/audit?[export_url_vars audit_name audit_id audit_id_column return_url audit_tables main_tables]\">
	Audit Links from $product_name</a>
      </li>"

set audit_name "Links to $product_name"
set audit_id_column "product_b"

doc_body_append "
     <li>
       <a href=\"[ec_url_concat [ec_url] /admin]/audit?[export_url_vars audit_name audit_id audit_id_column return_url audit_tables main_tables]\">
       Audit Links to $product_name</a>
    </li>
  </ul>
  [ad_admin_footer]"
