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

set title "Product Recommendations"
set context [list [list index Products] $title]

# For Audit tables
set table_names_and_id_column [list ec_product_recommendations ec_product_recommend_audit product_id]

set the_category_name ""
set the_subcategory_name ""
set the_subsubcategory_name ""
set moby_string ""

db_foreach recommendations_select "select 
  r.recommendation_id, r.the_category_name, r.the_subcategory_name, r.the_subsubcategory_name,
  p.product_name, 
  c.user_class_name
from ec_recommendations_cats_view r, ec_products p, ec_user_classes c
where r.active_p='t'
and r.user_class_id = c.user_class_id(+)
and r.product_id = p.product_id
order by decode(the_category_name,NULL,0,1), upper(the_category_name), upper(the_subcategory_name), upper(the_subsubcategory_name)" {
    if { [string length $the_category_name] > 0 } {
        append the_category_name " &gt; "
    }
    if { [string length $the_subcategory_name] > 0 } {
        append the_subcategory_name " &gt; "
    }
    if { [string length $the_subsubcategory_name] > 0 } {
        append the_subsubcategory_name " &gt; "
    }

    append moby_string "<li>$the_category_name $the_subcategory_name $the_subsubcategory_name <a href=\"recommendation?[export_url_vars recommendation_id]\">$product_name</a> [ec_decode $user_class_name "" "" "($user_class_name)"]</li>\n"
    set the_category_name ""
    set the_subcategory_name ""
    set the_subsubcategory_name ""
}

set audit_url_html "[ec_url_concat [ec_url] /admin]/audit-tables?[export_url_vars table_names_and_id_column]"

