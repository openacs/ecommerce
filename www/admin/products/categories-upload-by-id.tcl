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

doc_body_append "[ad_admin_header "Upload Category Mapping Data"]

<h2>Upload Category Mapping Data by category id indexes</h2>

[ad_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index.tcl" "Products"] "Upload Category Mapping Data"]

<hr>

<blockquote>

<form enctype=\"multipart/form-data\" action=\"categories-upload-by-id-2\" method=\"post\">
Data Filename <input name=\"csv_file\" type=\"file\">
<br>
<input type=\"radio\" name=\"file_type\" value=\"csv\" checked>CSV format<br>
<input type=\"radio\" name=\"file_type\" value=\"tab\">Tab Delimited format<br>
<input type=\"radio\" name=\"file_type\" value=\"delim\">Delimited by: <input name=\"delimiter\" value=\" \" type=\"text\"> (single character).<br>
<p>
<center>
<input type=\"submit\" value=\"Upload\">
</center>
</form>

<p>

<b>Notes:</b>
</p>
<blockquote>
<p>

 This page uploads a data file containing product category mappings using (sub)(sub)category_id 
 values from <tt>ec_categories</tt>, <tt>ec_subcategories</tt>, and <tt>ec_subsubcategories</tt> tables.
<p>
 The file format should be:
</p><p>
<blockquote>
<code>sku_1, category_id_1, subcategory_id_1, subsubcategory_id_1<br>
sku_2, category_id_2, subcategory_id_2, subsubcategory_id_2<br>
...<br>
sku_n,  category_id_n, subcategory_id_n, subsubcategory_id_n</code>
</blockquote>
<p>
 Where each line contains a sku and category id set.  There may be multiple lines for a single sku
 which will cause the product to get placed in multiple categories (or subcategories etc.)
</p><p>
 If a subcategory match is found, the product is placed into the matching parent category 
 of the matching subcategory as well as the subcategory. If no match is found for 
 a product, no mapping entry is made.
</p>
</blockquote>
</blockquote>

[ad_admin_footer]
"
