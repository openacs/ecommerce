#  www/[ec_url_concat [ec_url] /admin]/products/sale-price-edit-3.tcl
ad_page_contract {
  Update a sale price.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id sale-price-edit-3.tcl,v 3.2.2.3 2000/08/18 20:23:47 stevenp Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  sale_price_id:integer,notnull
  product_id:integer,notnull
  sale_price:notnull
  sale_name
  sale_begins
  sale_ends
  offer_code
}
# check the validity of sale price
ad_require_permission [ad_conn package_id] admin

if {![regexp {^[0-9|.]+$}  $sale_price  match ] } {
    ad_return_complaint 1 "<li>Please enter a number for sale price."
    return
} 
if {[regexp {^[.]$}  $sale_price match ]} {
    ad_return_complaint 1 "<li>Please enter a number for the sale price."
    return
}

# we need them to be logged in
ad_maybe_redirect_for_registration
set user_id [ad_get_user_id]

set peeraddr [ns_conn peeraddr]

db_dml sale_price_update "
update ec_sale_prices
set sale_price=:sale_price,
    sale_begins=to_date(:sale_begins,'YYYY-MM-DD HH24:MI:SS'),
    sale_ends=to_date(:sale_ends,'YYYY-MM-DD HH24:MI:SS'),
    sale_name=:sale_name,
    offer_code=:offer_code,
    last_modified=sysdate,
    last_modifying_user=:user_id,
    modified_ip_address=:peeraddr
where sale_price_id=:sale_price_id
"

ad_returnredirect "sale-prices.tcl?[export_url_vars product_id]"
