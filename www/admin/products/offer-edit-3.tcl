#  www/[ec_url_concat [ec_url] /admin]/products/offer-edit-3.tcl
ad_page_contract {
  Edit an offer.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id offer-edit-3.tcl,v 3.1.6.2 2000/07/22 07:57:40 ron Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  offer_id:integer,notnull
  product_id:integer,notnull
  retailer_id:integer,notnull
  price
  shipping
  stock_status
  old_retailer_id:integer,notnull
  offer_begins
  offer_ends
  special_offer_p
  special_offer_html:html
  shipping_unavailable_p:optional
}

ad_require_permission [ad_conn package_id] admin

# we need them to be logged in
set user_id [ad_conn user_id]

if { [info exists shipping_unavailable_p] } {
    set additional_thing_to_insert ", shipping_unavailable_p='t'"
} else {
    set additional_thing_to_insert ", shipping_unavailable_p='f'"
}

set peeraddr [ns_conn peeraddr]

db_dml unused "
update ec_offers
set retailer_id = :retailer_id,
    price = :price,
    shipping = :shipping,
    stock_status = :stock_status,
    special_offer_p = :special_offer_p,
    special_offer_html = :special_offer_html,
    offer_begins = to_date(:offer_begins, 'YYYY-MM-DD HH24:MI:SS'),
    offer_ends = to_date(:offer_ends, 'YYYY-MM-DD HH24:MI:SS') $additional_thing_to_insert,
    last_modified = sysdate,
    last_modifying_user = :user_id,
    modified_ip_address = :peeraddr
where offer_id = :offer_id
"

ad_returnredirect "offers.tcl?[export_url_vars product_id]"
