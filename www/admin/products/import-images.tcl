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

doc_body_append "[ad_admin_header "Bulk Import Product Images"]

<h2>Bulk Import Product Images</h2>

[ad_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index.tcl" "Products"] "Bulk Import Product Images"]

<hr>

<blockquote>

<form enctype=\"multipart/form-data\" action=\"import-images-2\" method=\"post\">
Data Filename <input name=\"csv_file\" type=\"file\">
<br>
<input type=\"radio\" name=\"file_type\" value=\"csv\" checked>CSV format<br>
<input type=\"radio\" name=\"file_type\" value=\"tab\">Tab Delimited format<br>
<input type=\"radio\" name=\"file_type\" value=\"delim\">Delimited by: <input name=\"delimiter\" value=\" \" type=\"text\"> (single character).<br>
 <br>
<center>
<input type=\"submit\" value=\"Import\">
</center>
</form>

<p>

<b>Notes:</b>
</p>

<p>

    This page uploads a data file containing product information to bulk import product images into the catalog.  The file format should be:
</p><p>
<blockquote>
<code>field_name_1, field_name_2, ... field_name_n<br>
value_1, value_2, ... value_n</code>
</blockquote>
<p>
    where the first line contains the actual names of the columns and 
    the remaining lines contain the values for the specified fields, one line per product.
</p>
</blockquote>
<p>
    <tt>sku</tt> and <tt>image_fullpathname</tt> are the only fields used. All other field names and values are ignored. <tt>sku</tt> should contain product sku values. <tt>image_fullpathname</tt> should contain absolute file references, one per sku. For example a value for image_fullpathname might look like: <tt>/var/tmp/boots/sidekick-3000.jpg</tt>
</p>
<p>

[ad_admin_footer]
"
