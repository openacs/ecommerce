#  www/[ec_url_concat [ec_url] /admin]/products/offer-edit.tcl
ad_page_contract {
  Edit an offer.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  offer_id:integer,notnull
  product_id:integer,notnull
  retailer_id:integer,notnull
}

ad_require_permission [ad_conn package_id] admin

set product_name [ec_product_name $product_id]

set title "Edit Retailer Offer on $product_name"
set context [list [list index Products] $title]

set old_retailer_id $retailer_id
set export_form_vars_html [export_form_vars offer_id product_id product_name old_retailer_id]

set retailer_select_html ""
db_foreach retailer_select "
select retailer_name, retailer_id, city, usps_abbrev
from ec_retailers
order by retailer_name" {
    if { $retailer_id == $old_retailer_id } {
	append retailer_select_html "<option value=$retailer_id selected>$retailer_name ($city, $usps_abbrev)\n"
    } else {
	append retailer_select_html "<option value=$retailer_id>$retailer_name ($city, $usps_abbrev)\n"
    }
}

db_1row offer_select "
select price, shipping, stock_status, shipping_unavailable_p, offer_begins,
       offer_ends, special_offer_p, special_offer_html from ec_offers
where offer_id=:offer_id"

set currency [parameter::get -package_id [ec_id] -parameter Currency -default "USD"]

set stock_status_html [ec_stock_status_widget $stock_status]

set offer_begins_html "[ad_dateentrywidget offer_begins $offer_begins]"
set offer_ends_html "[ad_dateentrywidget offer_ends $offer_ends]""

