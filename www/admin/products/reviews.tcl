#  www/[ec_url_concat [ec_url] /admin]/products/reviews.tcl
ad_page_contract {
  Summarize professional reviews of one product and let site owner
  add a new review.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date June 1999
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  product_id:integer,notnull
}

ad_require_permission [ad_conn package_id] admin

set product_name [ec_product_name $product_id]
set title "Professional Reviews of $product_name"
set context [list [list index Products] $title]

set review_counter 0
set product_reviews_select_html ""
db_foreach product_reviews_select "
    select review_id, author_name, publication, review_date, display_p
    from ec_product_reviews
    where product_id=:product_id" {
    incr review_counter
    append product_reviews_select_html "<li><a href=\"review?[export_url_vars review_id]\">[ec_product_review_summary $author_name $publication $review_date]</a>"
    if { $display_p != "t" } {
        append product_reviews_select_html " (this will not be displayed on the site)"
    }
    append product_reviews_select_html "</li>"
}

set export_form_vars_html [export_form_vars product_id]
set review_date_html [ad_dateentrywidget review_date]
