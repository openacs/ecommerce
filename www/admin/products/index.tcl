#  www/[ec_url_concat [ec_url] /admin]/products/index.tcl
ad_page_contract {
  The main admin page for products.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id index.tcl,v 3.1.6.2 2000/07/22 07:57:39 ron Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
}

ad_require_permission [ad_conn package_id] admin

doc_body_append "[ad_admin_header "Product Administration"]

<h2>Product Administration</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] "Products"]

<hr>

"

# For Audit tables
set table_names_and_id_column [list ec_products ec_products_audit product_id]



db_1row products_select "select count(*) as n_products, round(avg(price),2) as avg_price from ec_products_displayable"

doc_body_append "

<ul>

<li>$n_products products 
(<a href=\"list\">All</a> | 
<a href=\"by-category\">By Category</a> |
<a href=\"add\">Add</a>)

<p>

<li><a href=\"recommendations\">Recommendations</a>
<li><a href=\"../cat/\">Categorization</a>
<li><a href=\"custom-fields\">Custom Fields</a>
<li><a href=\"upload-utilities\">Bulk upload products</a>

<p>

<form method=post action=search>
<li>Search by Name: <input type=text name=product_name size=20>
<input type=submit value=\"Search\">
</form>

<p>

<form method=post action=search>
<li>Search by SKU: <input type=text name=sku size=3>
<input type=submit value=\"Search\">
</form>

<p>

<li><a href=\"[ec_url_concat [ec_url] /admin]/audit-tables?[export_url_vars table_names_and_id_column]\">Audit all Products</a>
</ul>

[ad_admin_footer]
"
