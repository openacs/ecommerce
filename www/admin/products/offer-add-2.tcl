#  www/[ec_url_concat [ec_url] /admin]/products/offer-add-2.tcl
ad_page_contract {
  Add an offer.

  @author
  @creation-date
  @cvs-id offer-add-2.tcl,v 3.1.6.2 2000/07/22 07:57:40 ron Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  offer_id:integer,notnull
  product_id:integer,notnull
  retailer_id:integer,notnull
  price
  shipping
  stock_status
  offer_begins
  offer_ends
  special_offer_p
  special_offer_html:html
  shipping_unavailable_p:optional
}

ad_require_permission [ad_conn package_id] admin

# we need them to be logged in
set user_id [ad_conn user_id]

set product_name [ec_product_name $product_id]

# see if an offer with this offer_id exists, meaning they pushed
# submit twice

if { [db_string doubleclick_select "select count(*) from ec_offers where offer_id=:offer_id"] > 0 } {
    ad_returnredirect "offers.tcl?[export_url_vars product_id]"
    return
}

if { [info exists shipping_unavailable_p] } {
    set additional_column ", shipping_unavailable_p"
    set additional_value ", 't'"
} else {
    set additional_column ""
    set additional_value ""
}

set peeraddr [ns_conn peeraddr]

db_dml offer_insert "
insert into ec_offers
(offer_id, product_id, retailer_id, price, shipping, stock_status,
 special_offer_p, special_offer_html, offer_begins,
 offer_ends $additional_column, last_modified, last_modifying_user,
 modified_ip_address)
values
(:offer_id, :product_id, :retailer_id, :price, :shipping, :stock_status,
 :special_offer_p, :special_offer_html,
 to_date(:offer_begins, 'YYYY-MM-DD HH24:MI:SS'),
 to_date(:offer_ends,'YYYY-MM-DD HH24:MI:SS') $additional_value, sysdate,
 :user_id, :peeraddr)
"

ad_returnredirect "offers.tcl?[export_url_vars product_id]"
