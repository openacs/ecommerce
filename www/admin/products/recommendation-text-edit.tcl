#  www/[ec_url_concat [ec_url] /admin]/products/recommendation-text-edit.tcl
ad_page_contract {
  Entry form to let user edit the HTML text of a recommendation.

  @author philg@mit.edu on 
  @creation-date July 18, 1999
  @cvs-id recommendation-text-edit.tcl,v 3.1.6.5 2000/09/22 01:34:59 kevin Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  recommendation_id:integer,notnull
}

ad_require_permission [ad_conn package_id] admin

db_1row recommendation_select "select r.*, p.product_name
from ec_product_recommendations r, ec_products p
where recommendation_id=$recommendation_id

and r.product_id=p.product_id"

 
doc_return  200 text/html "[ad_admin_header "Edit Product Recommendation Text"]

<h2>Edit Recommendation Text</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index.tcl" "Products"] [list "recommendations.tcl" "Recommendations"] [list "recommendation.tcl?[export_url_vars recommendation_id]" "One"] "Edit Recommendation"]

<hr>

Edit text for the recommendation of $product_name:

<blockquote>
<form method=GET action=\"recommendation-text-edit-2\">
[export_form_vars recommendation_id]
<textarea name=recommendation_text rows=10 cols=70 wrap=soft>
[ns_quotehtml $recommendation_text]
</textarea>
<p>
<center>
<input type=submit value=\"Update\">
</form>
</center>
</blockquote>

[ad_admin_footer]
"
