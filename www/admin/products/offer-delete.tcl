#  www/[ec_url_concat [ec_url] /admin]/products/offer-delete.tcl
ad_page_contract {
  Delete or undelete an offer.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  deleted_p
  product_id:integer,notnull
  retailer_id:integer,notnull
}

ad_require_permission [ad_conn package_id] admin

set product_name [ec_product_name $product_id]

if { $deleted_p == "t" } {
    set delete_or_undelete "Delete"
    set deletion_or_undeletion "Deletion"
} else {
    set delete_or_undelete "Undelete"
    set deletion_or_undeletion "Undeletion"
}
set title "Confirm $deletion_or_undeletion of Retailer Offer on $product_name"
set context [list [list index Products] $title]

set export_form_vars_html [export_form_vars deleted_p product_id retailer_id]
