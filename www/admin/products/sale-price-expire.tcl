#  www/[ec_url_concat [ec_url] /admin]/products/sale-price-expire.tcl
ad_page_contract {
  Confirm sale expire.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id sale-price-expire.tcl,v 3.1.6.1 2000/07/22 07:57:45 ron Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  sale_price_id:integer,notnull
  product_id:integer,notnull
}

ad_require_permission [ad_conn package_id] admin

set product_name [ec_product_name $product_id]

doc_body_append "[ad_admin_header "Expire Sale Price for $product_name"]

<h2>Expire Sale Price for $product_name</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index.tcl" "Products"] [list "one.tcl?[export_url_vars product_id]" $product_name] "Expire Sale Price"]

<hr>

Please confirm that you want to end the sale price right now.

<form method=post action=sale-price-expire-2>

[export_form_vars product_id sale_price_id]

<p>

<center>
<input type=submit value=\"Confirm\">
</center>

</form>

[ad_admin_footer]
"