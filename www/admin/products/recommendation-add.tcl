#  www/[ec_url_concat [ec_url] /admin]/products/recommendation-add.tcl
ad_page_contract {
  Search for a product to recommend.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  product_name_query
}

ad_require_permission [ad_conn package_id] admin

set header_to_print "Please choose the product you wish to recommend.
<ul>
"
doc_body_append "[ad_admin_header "Add a Product Recommendation"]

<h2>Add a Product Recommendation</h2>

[ad_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index.tcl" "Products"] [list "recommendations.tcl" "Recommendations"] "Add One"]

<hr>
"

set header_written_p 0
db_foreach product_search_select "
select product_name, product_id
from ec_products
where upper(product_name) like '%' || upper(:product_name_query) || '%'
" {
  if { $header_written_p == 0 } {
    doc_body_append $header_to_print
    incr header_written_p
  }
  doc_body_append "<li>$product_name \[<a href=\"one?[export_url_vars product_id]\">view</a> | <a href=\"recommendation-add-2?[export_url_vars product_name product_id]\">recommend</a>\] ($product_id)\n"
}

if { $header_written_p } {
  doc_body_append "</ul>"
} else {
  doc_body_append "No matching products were found."
}

doc_body_append "[ad_admin_footer]
"
