#  www/[ec_url_concat [ec_url] /admin]/products/delete.tcl
ad_page_contract {
  Product delete confirm.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id delete.tcl,v 3.1.6.1 2000/07/22 07:57:38 ron Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  product_id:integer,notnull
}

ad_require_permission [ad_conn package_id] admin

set product_name [ec_product_name $product_id]

doc_body_append "[ad_admin_header "Confirm Deletion of $product_name"]

<h2>Confirm Deletion</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index.tcl" "Products"] [list "one.tcl?[export_url_vars product_id]" "One"] "Confirm Deletion"]

<hr>

Are you sure you want to delete $product_name?  Note that the system
will not let you delete a product if anyone has already ordered it
(you might want to mark the product \"discontinued\" instead).

<p>
<form method=post action=delete-2>
[export_form_vars product_id]
<center>
<input type=submit value=\"Yes\">
</center>
</form>

[ad_admin_footer]
"
