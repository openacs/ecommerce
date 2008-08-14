#  www/[ec_url_concat [ec_url] /admin]/products/categories-upload.tcl
ad_page_contract {
  This page uploads a data file containing product categories mapped to
  products. 

  The file format should be:

    sku_1, category_id_1, subcategory_id_1, subsubcategory_id_1
    sku_2, category_id_2, subcategory_id_2, subsubcategory_id_2
    ...
    sku_n, category_id_n, subcategory_id_n, subsubcategory_id_n

  Where each line contains a sku and category id set. There may
  be multiple lines for a single product(sku) which will cause the
  product to get placed in multiple categories (or subcategories etc.)

  This program matches existing products to existing category_id's 
  by matching category_id, subcategory_id, and subsubcategory_id values
  to the same three values in the ec_categories, ec_subcategories, and ec_subsubcategories
  tables.
  
  If a subcategory match is found, the product is placed into the
  matching subcategory. If no match is found for a product, no mapping entry is
  made. A sku may appear on multiple lines to place a product
  in multiple categories.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
  @revised by Torben Brosten (torben@kappacorp.com)
  @revised from categories-upload.tcl
  @revision-date February 2004
} {
}

ad_require_permission [ad_conn package_id] admin

set title "Uploading Category Mapping Data by category id indexes"
set context [list [list index Products] $title]
