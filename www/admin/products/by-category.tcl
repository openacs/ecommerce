#  www/[ec_url_concat [ec_url] /admin]/products/by-category.tcl
ad_page_contract {
  List the product categories and summary data for each (how many
  products, how many sales).

  @author philg@mit.edu
  @creation-date July 18, 1999
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
}

ad_require_permission [ad_conn package_id] admin

doc_body_append "[ad_admin_header "Products by Category"]

<h2>Products by category</h2>

[ad_admin_context_bar [list "[ec_url_concat [ec_url] /admin]/" "Ecommerce([ec_system_name])"] [list "index.tcl" "Products"] "by Category"]

<hr>

<ul>
"

set items ""

db_foreach product_categories_select "
select cats.category_id, cats.sort_key, cats.category_name, count(cat_view.product_id) as n_products, sum(cat_view.n_sold) as total_sold_in_category
from 
  ec_categories cats, 
  (select map.product_id, map.category_id, count(i.item_id) as n_sold
   from ec_category_product_map map, ec_items_reportable i
   where map.product_id = i.product_id(+)
   group by map.product_id, map.category_id) cat_view
where cats.category_id = cat_view.category_id(+)
group by cats.category_id, cats.sort_key, cats.category_name
order by cats.sort_key" {
    append items "<li><a href=\"list?[export_url_vars category_id]\">$category_name</a> 
&nbsp;
<font size=-1>($n_products products; $total_sold_in_category sales)</font>\n"
}

if ![empty_string_p $items] {
    doc_body_append $items
} else {
    doc_body_append "apparently products aren't being put into categories"
}

doc_body_append "

</ul>

[ad_admin_footer]
"

