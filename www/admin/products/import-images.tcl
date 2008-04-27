#  www/[ec_url_concat [ec_url] /admin]/products/import-images.tcl
ad_page_contract {
  This page uploads a data file containing store-specific 
  product references and new product images pathnames
  for bulk importing images and thumbnails into ecommerce.
  The file format should be:

    field_name_1, field_name_2, ... field_name_n
    value_1, value_2, ... value_n

  where the first line contains the actual names of the columns in
  ec_products and the remaining lines contain the values for the
  specified fields, one line per product.

  Legal values for field names are the columns in ec_products (see
  ecommerce/sql/ecommerce-create.sql for current column names):

    sku
    image_pathname 

  Note: product_id, dirname, creation_date, available_date, last_modified,
  last_modifying_user and modified_ip_address are set automatically
  and should not appear in the data file.

  @author Torben Brosten (torben@kappacorp.com)
  @creation-date Spring 2005
  @cvs-id $Id$
} {
}

ad_require_permission [ad_conn package_id] admin

set page_title "Bulk Import Product Images"
set context_bar [template::adp_parse [acs_root_dir]/packages/[ad_conn package_key]/www/contextbar [list context_addition "Bulk Import Product Images"]]

