#  www/[ec_url_concat [ec_url] /admin]/products/review-add.tcl
ad_page_contract {
  Review confirmation page.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id review-add.tcl,v 3.1.6.3 2000/08/18 20:23:46 stevenp Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  product_id:integer,notnull
  publication
  display_p
  review:html
  author_name
  review_date:array,date
}

ad_require_permission [ad_conn package_id] admin

page_validation {
#  ec_date_widget_validate review_date
}

set product_name [ec_product_name $product_id]

doc_body_append "[ad_admin_header "Confirm Review of $product_name"]

<h2>Confirm Review of $product_name</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index.tcl" "Products"] [list "one.tcl?[export_url_vars product_id]" $product_name] [list "reviews.tcl?[export_url_vars product_id product_name]" "Professional Reviews"] "Confirm Review"]

<hr>

<table>
<tr>
<td>Summary</td>
<td>[ec_product_review_summary $author_name $publication [ec_date_text review_date]]</td>
</tr>
<tr>
<td>Display on web site?</td>
<td>[util_PrettyBoolean $display_p]</td>
</tr>
<tr>
<td>Review</td>
<td>$review</td>
</tr>
</table>
"


set review_id [db_nextval ec_product_review_id_sequence]

doc_body_append "<form method=post action=review-add-2>
[export_form_vars product_id publication display_p review review_id author_name]
<input type=hidden name=review_date value=\"[ec_date_text review_date]\">

<center>
<input type=submit value=\"Confirm\">
</center>
</form>

[ad_admin_footer]
"
