#  www/[ec_url_concat [ec_url] /admin]/products/review-add-2.tcl
ad_page_contract {
  Submit a review.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  product_id:integer,notnull
  publication
  display_p
  review:html
  review_id:integer,notnull
  author_name
  review_date
}

ad_require_permission [ad_conn package_id] admin

# we need them to be logged in
set user_id [ad_get_user_id]

# see if this review is already there
if { [db_string doubleclick_select "select count(*) from ec_product_reviews where review_id=:review_id"] > 0 } {
    ad_returnredirect "reviews.tcl?[export_url_vars product_id]"
    ad_script_abort
}

set peeraddr [ns_conn peeraddr]

db_dml review_insert "insert into ec_product_reviews
(review_id, product_id, publication, author_name, review, display_p, review_date, last_modified, last_modifying_user, modified_ip_address)
values
(:review_id, :product_id, :publication, :author_name, :review, :display_p, to_date(:review_date, 'YYYY-MM-DD HH24:MI:SS'), sysdate, :user_id, :peeraddr)
"

ad_returnredirect "reviews.tcl?[export_url_vars product_id]"
