#  www/[ec_url_concat [ec_url] /admin]/products/link-delete-2.tcl
ad_page_contract {
  Delete a product link.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  product_a:integer,notnull
  product_b:integer,notnull
  product_id:integer,notnull
}

ad_require_permission [ad_conn package_id] admin

set product_name [ec_product_name $product_id]

db_transaction {
  db_dml link_delete "delete from ec_product_links where product_a=:product_a and product_b=:product_b"

  ec_audit_delete_row [list $product_a $product_b] [list "product_a" "product_b"] ec_product_links_audit
}

ad_returnredirect "link.tcl?[export_url_vars product_id]"
