#  www/[ec_url_concat [ec_url] /admin]/products/recommendations.tcl
ad_page_contract {
  Product recomendations.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
}

ad_require_permission [ad_conn package_id] admin

doc_body_append "[ad_admin_header "Product Recommendations"]

<h2>Product Recommendations</h2>

[ad_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index.tcl" "Products"] "Recommendations"]

<hr>

<h3>Currently Recommended Products</h3>

These products show up when the customer is browsing the site, either on the
home page (if a product is recommended at the top level), or when the
customer is browsing categories, subcategories, or subsubcategories.

<p>

You can also associate product recommendations with a user classs if you
only want people in that user class to see a given recommendation.

<ul>

"

# For Audit tables
set table_names_and_id_column [list ec_product_recommendations ec_product_recommend_audit product_id]



set last_category ""
set last_subcategory ""
set last_subsubcategory ""
set subcat_ul_open_p 0
set subsubcat_ul_open_p 0

set moby_string ""

db_foreach recommendations_select "
select 
  r.recommendation_id, r.the_category_name, r.the_subcategory_name, r.the_subsubcategory_name,
  p.product_name, 
  c.user_class_name
from ec_recommendations_cats_view r, ec_products p, ec_user_classes c
where r.active_p='t'
and r.user_class_id = c.user_class_id(+)
and r.product_id = p.product_id
order by decode(the_category_name,NULL,0,1), upper(the_category_name), upper(the_subcategory_name), upper(the_subsubcategory_name)" {
    if { $the_category_name != $last_category } {
	append moby_string "<h4>$the_category_name</h4>\n"
	set last_category $the_category_name
	set last_subcategory ""
	set last_subsubcategory ""
    }
    if { $the_subcategory_name != $last_subcategory } {
	if $subsubcat_ul_open_p {
	    append moby_string "</ul>"
	    set subsubcat_ul_open_p 0
	}
	if $subcat_ul_open_p {
	    append moby_string "</ul>"
	    set subcat_ul_open_p 0
	}
	append moby_string "<ul><h5>$the_subcategory_name</h5>\n"
	set last_subcategory $the_subcategory_name
	set last_subsubcategory ""
	set subcat_ul_open_p 1
    }
    if { $the_subsubcategory_name != $last_subsubcategory } {
	if $subsubcat_ul_open_p {
	    append moby_string "</ul>"
	    set subsubcat_ul_open_p 0
	}
	append moby_string "<ul><h6>$the_subsubcategory_name</h6>"
	set last_subsubcategory $
	set subsubcat_ul_open_p 1
    }
    append moby_string "<li><a href=\"recommendation?[export_url_vars recommendation_id]\">$product_name</a> [ec_decode $user_class_name "" "" "($user_class_name)"]\n"
}

if $subsubcat_ul_open_p {
    append moby_string "</ul>"
    set subsubcat_ul_open_p 0
}
if $subcat_ul_open_p {
    append moby_string "</ul>"
    set subcat_ul_open_p 0
}

doc_body_append "

$moby_string

</ul>

<h3>Add a Recommendation</h3>

<form method=post action=recommendation-add>

<blockquote>
Search for a product to recommend:
<input type=text size=15 name=product_name_query>
<input type=submit value=\"Search\">
</blockquote>

<h3>Options</h3>
<ul>

<li><a href=\"[ec_url_concat [ec_url] /admin]/audit-tables?[export_url_vars table_names_and_id_column]\">Audit all Recommendations</a>

</ul>
[ad_admin_footer]
"
