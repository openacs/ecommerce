#  www/[ec_url_concat [ec_url] /admin]/products/sale-price-expire-2.tcl
ad_page_contract {
  Expire a sale.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id sale-price-expire-2.tcl,v 3.1.6.3 2000/08/18 20:23:47 stevenp Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  sale_price_id:integer,notnull
  product_id:integer,notnull
}

ad_require_permission [ad_conn package_id] admin

# we need them to be logged in
set user_id [ad_get_user_id]

set peeraddr [ns_conn peeraddr]

db_dml expire_sale_update "
update ec_sale_prices
set sale_ends=sysdate,
    last_modified=sysdate,
    last_modifying_user=:user_id,
    modified_ip_address=:peeraddr
where sale_price_id=:sale_price_id
"
db_release_unused_handles

ad_returnredirect "sale-prices.tcl?[export_url_vars product_id]"
