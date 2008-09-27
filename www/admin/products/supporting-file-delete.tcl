#  www/[ec_url_concat [ec_url] /admin]/products/supporting-file-delete.tcl
ad_page_contract {
  Confirm delete of a file.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  product_id:integer,notnull
  file
}

ad_require_permission [ad_conn package_id] admin

set product_name [ec_product_name $product_id]
set title "Delete Supporting File for $product_name"
set context [list [list index Products] $title]
set comments ""
if { [string match "product*.jpg" $file] || [string match "product.gif" $file] } {
    set comments "Note: this file is a picture of the product.  If you delete it, the customer will not be able to see what the product looks like."
}
set export_form_vars_html [export_form_vars file product_id]
