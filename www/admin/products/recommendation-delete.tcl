#  www/[ec_url_concat [ec_url] /admin]/products/recommendation-delete.tcl
ad_page_contract {
  Confirmation page, takes no action.

  @author philg@mit.edu
  @creation-date July 18, 1999
  @cvs-id recommendation-delete.tcl,v 3.1.6.4 2000/09/22 01:34:59 kevin Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  recommendation_id:integer,notnull
}

ad_require_permission [ad_conn package_id] admin

db_1row recommendation_select "select r.*, p.product_name
from ec_product_recommendations r, ec_products p
where recommendation_id=:recommendation_id
and r.product_id=p.product_id"

if { ![empty_string_p $user_class_id] } {
    set user_class_description "to [db_string user_class_name_select "select user_class_name from ec_user_classes where user_class_id=:user_class_id"]"
} else {
    set user_class_description "to all users"
}


doc_return  200 text/html "[ad_admin_header "Really Delete Product Recommendation?"]

<h2>Confirm</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index.tcl" "Products"] [list "recommendations.tcl" "Recommendations"] [list "recommendation.tcl?[export_url_vars recommendation_id]" "One"] "Confirm Deletion"]

<hr>

Are you sure that you want to delete this recommendation of 
$product_name ($user_class_description)?

<center>
<form method=GET action=\"recommendation-delete-2\">
[export_form_vars recommendation_id]
<input type=submit value=\"Yes, I'm sure\">
</form>
</center>

[ad_admin_footer]
"
