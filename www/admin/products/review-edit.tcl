#  www/[ec_url_concat [ec_url] /admin]/products/review-edit.tcl
ad_page_contract {
  Edit a review.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id review-edit.tcl,v 3.1.6.3 2000/08/18 20:23:46 stevenp Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  product_id:integer,notnull
  publication
  author_name
  review_date:array,date
  display_p
  review:html
  review_id:integer,notnull
}

ad_require_permission [ad_conn package_id] admin

page_validation {
#  ec_date_widget_validate review_date
}

# we need them to be logged in
set user_id [ad_get_user_id]

set peeraddr [ns_conn peeraddr]

db_dml product_review_update "
update ec_product_reviews
set product_id=:product_id,
    publication=:publication,
    author_name=:author_name,
    review_date=[ec_datetime_sql review_date],
    review=:review,
    display_p=:display_p,
    last_modified=sysdate,
    last_modifying_user=:user_id,
    modified_ip_address=:peeraddr
where review_id=:review_id
"

ad_returnredirect "review.tcl?[export_url_vars review_id]"
