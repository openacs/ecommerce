#  www/[ec_url_concat [ec_url] /admin]/products/recommendation.tcl
ad_page_contract {
  Display one recommendation.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  recommendation_id:integer,notnull
}

ad_require_permission [ad_conn package_id] admin

db_1row recommendation_select "select r.*, p.product_name
from  ec_recommendations_cats_view r, ec_products p
where recommendation_id=:recommendation_id
and r.product_id=p.product_id"

doc_body_append "[ad_admin_header "Product Recommendation"]

<h2>Product Recommendation</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index.tcl" "Products"] [list "recommendations.tcl" "Recommendations"] "One"]

<hr>

<blockquote>

<table cellpadding=10>
<tr>
<td>Product:</td>
<td>$product_name</td>
</tr>
<tr>
<td>Recommended For:</td>
"
if { ![empty_string_p $user_class_id] } {
    doc_body_append "<td>[db_string user_class_name_select "select user_class_name from ec_user_classes where user_class_id=:user_class_id"]</td>
    "
} else {
    doc_body_append "<td>All Users</td>
    "
}
doc_body_append "</tr>
<tr>
<td>Display Recommendation In:</td>
"
if { [empty_string_p $the_category_id] && [empty_string_p $the_subcategory_id] && [empty_string_p $the_subsubcategory_id] } {
    doc_body_append "<td>Top Level</td>"
} else {
    doc_body_append "<td>[ec_category_subcategory_and_subsubcategory_display $the_category_id $the_subcategory_id $the_subsubcategory_id]</td>"
}

doc_body_append "</tr>
<tr>
<td valign=top>Accompanying Text<br>(HTML format):</td>
<td valign=top>$recommendation_text
<p>
(<a href=\"recommendation-text-edit?[export_url_vars recommendation_id]\">edit</a>)
</td>
</tr>
</table>

</blockquote>
"

# Set audit variables
# audit_name, audit_id, audit_id_column, return_url, audit_tables, main_tables
set audit_name Recommendation
set audit_id $recommendation_id
set audit_id_column "recommendation_id"
set return_url "[ad_conn url]?[export_url_vars product_id]"
set audit_tables [list ec_product_recommend_audit]
set main_tables [list ec_product_recommendations]

doc_body_append "
<ul>
<li><a href=\"[ec_url_concat [ec_url] /admin]/audit?[export_url_vars audit_name audit_id audit_id_column return_url audit_tables main_tables]\">Audit Trail</a>

<p>

<li><a href=\"recommendation-delete?[export_url_vars recommendation_id]\">Delete</a>

</ul>

[ad_admin_footer]
"
