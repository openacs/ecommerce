# /www/[ec_url_concat [ec_url] /admin]/orders/items-add.tcl
ad_page_contract {

  Add an item to an order.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id items-add.tcl,v 3.2.2.2 2000/08/16 21:19:21 seb Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  order_id:integer,notnull
}

ad_require_permission [ad_conn package_id] admin

doc_body_append "[ad_admin_header "Add Items"]

<h2>Add Items</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index" "Orders"] [list "one?order_id=$order_id" "One Order"] "Add Items"]

<hr>
<blockquote>
Search for a product to add:

<ul>

<form method=post action=items-add-2>
[export_form_vars order_id]
<li>By Name: <input type=text name=product_name size=20>
<input type=submit value=\"Search\">
</form>

<p>

<form method=post action=items-add-2>
[export_form_vars order_id]
<li>By ID: <input type=text name=product_id size=3>
<input type=submit value=\"Search\">
</form>

</ul>

</blockquote>
[ad_admin_footer]
"

