#  www/[ec_url_concat [ec_url] /admin]/products/recommendation-add-3.tcl
ad_page_contract {
  Recommend a product.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  product_id:integer,notnull
  user_class_id:integer
  recommendation_text:html
  categorization
}

ad_require_permission [ad_conn package_id] admin

set product_name [ec_product_name $product_id]

# deal w/categorization for display purposes
set category_list [list]
set subcategory_list [list]
set subsubcategory_list [list]
for { set counter 0 } { $counter < [llength $categorization] } {incr counter} {
    if { $counter == 0 } {
	lappend category_list [lindex $categorization 0]
    }
    if { $counter == 1 } {
	lappend subcategory_list [lindex $categorization 1]
    }
    if { $counter == 2 } {
	lappend subsubcategory_list [lindex $categorization 2]
    }
}


set recommendation_id [db_nextval ec_recommendation_id_sequence]

doc_body_append "[ad_admin_header "Confirm Product Recommendation"]

<h2>Confirm Product Recommendation</h2>

[ad_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index.tcl" "Products"] [list "recommendations.tcl" "Recommendations"] "Add One"]

<hr>

Please confirm your product recommendation:

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
    doc_body_append "<td>[db_string user_class_select "select user_class_name from ec_user_classes where user_class_id=:user_class_id"]</td>
    "
} else {
    doc_body_append "<td>All Users</td>
    "
}
doc_body_append "</tr>
<tr>
<td>Display Recommendation In:</td>
"
if { [empty_string_p $categorization] } {
    doc_body_append "<td>Top Level</td>"
} else {
    doc_body_append "<td>[ec_category_subcategory_and_subsubcategory_display $category_list $subcategory_list $subsubcategory_list]</td>"
}

doc_body_append "</tr>
<tr>
<td>Accompanying Text<br>(HTML format):</td>
<td>$recommendation_text</td>
</tr>
</table>

</blockquote>

<form method=post action=\"recommendation-add-4\">
[export_form_vars product_id product_name user_class_id recommendation_text recommendation_id categorization]

<center>
<input type=submit value=\"Confirm\">
</center>

</form>

[ad_admin_footer]
"
