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

doc_body_append "[ad_admin_header "Professional Reviews of $product_name"]

<h2>Professional Reviews</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index.tcl" "Products"] [list "one.tcl?[export_url_vars product_id]" "One Product"] "Professional Reviews"]

<hr>

<ul>
<li>Product Name:  $product_name
</ul>

<h3>Current Reviews</h3>
<ul>
"

set review_counter 0
db_foreach product_reviews_select "
select review_id, author_name, publication, review_date, display_p
from ec_product_reviews
where product_id=:product_id
" {
    incr review_counter
    doc_body_append "<li><a href=\"review?[export_url_vars review_id]\">[ec_product_review_summary $author_name $publication $review_date]</a>
    "
    if { $display_p != "t" } {
	doc_body_append " (this will not be displayed on the site)"
    }
}

if { $review_counter == 0 } {
    doc_body_append "There are no current reviews.\n"
}

doc_body_append "</ul>

<p>

<h3>Add a Review</h3>

<blockquote>
<form method=post action=review-add>
[export_form_vars product_id]

<table cellspacing=10>
<tr>
<td valign=top>
Publication
</td>
<td>
<input type=text name=publication size=20>
</td>
</tr>
<tr>
<td>
Reviewed By
</td>
<td>
<input type=text name=author_name size=20>
</td>
</tr>
<tr>
<td>
Reviewed On
</td>
<td>
[ad_dateentrywidget review_date]
</td>
</tr>
<tr>
<td>
Display on web site?
</td>
<td>
<input type=radio name=display_p value=\"t\" checked>Yes &nbsp;
<input type=radio name=display_p value=\"f\">No
</td>
</tr>
<tr>
<td valign=top>
Review<br>
(HTML format)
</td>
<td valign=top>
<textarea name=review rows=10 cols=50 wrap=soft></textarea>
</td>
</tr>
</table>

<p>

<center>
<input type=submit value=\"Add\">
</center>

</form>
</blockquote>

[ad_admin_footer]
"
