#  www/[ec_url_concat [ec_url] /admin]/products/offer-delete-2.tcl
ad_page_contract {
  Delete an offer.

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

# we need them to be logged in
set user_id [ad_maybe_redirect_for_registration]

set peeraddr [ns_conn peeraddr]

db_dml offer_delete_update "
update ec_offers
set deleted_p=:deleted_p,
    last_modified=sysdate,
    last_modifying_user=:user_id,
    modified_ip_address=:peeraddr
where product_id=:product_id
and retailer_id=:retailer_id
"

ad_returnredirect "offers.tcl?[export_url_vars product_id]"
