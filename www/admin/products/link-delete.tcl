#  www/[ec_url_concat [ec_url] /admin]/products/link-delete.tcl
ad_page_contract {

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id link-delete.tcl,v 3.1.6.1 2000/07/22 07:57:39 ron Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  product_a:integer,notnull
  product_b:integer,notnull
  product_id:integer,notnull
}

ad_require_permission [ad_conn package_id] admin

set product_name [ec_product_name $product_id]

doc_body_append "[ad_admin_header "Confirm Deletion"]

<h2>Confirm Deletion</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index.tcl" "Products"] [list "one.tcl?[export_url_vars product_id]" $product_name] "Delete Link"]

<hr>
Please confirm that you wish to delete this link.

<form method=post action=link-delete-2>

[export_form_vars product_id product_a product_b]

<center>
<input type=submit value=\"Confirm\">
</center>

</form>

[ad_admin_footer]
"
