#  www/[ec_url_concat [ec_url] /admin]/products/categories-upload.tcl
ad_page_contract {
  This page uploads a CSV file containing product category "hints" and
  creates product category mappings. This is probably not generally
  useful for people who have clean data...

  The file format should be:

    sku_1, category_description_1
    sku_2, category_description_2
    ...
    sku_n, category_description_n

  Where each line contains a sku, category name pair. There may
  be multiple lines for a single product id which will cause the
  product to get placed in multiple categories (or subcategories)

  This program attempts to match the category name to an existing
  category using looses matching (SQL: like) because some data is
  really nasty with lots of different formats for similar categories.
  Maybe loose matching should be an option.

  If a subcategory match is found, the product is placed into the
  matching subcategory as well as the parent category of the matching
  subcategory. If no match is found for a product, no mapping entry is
  made. A sku may appear on multiple lines to place a product
  in multiple categories.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
}

ad_require_permission [ad_conn package_id] admin

set title "Upload Category Mapping Data"
set context [list [list index Products] $title]



