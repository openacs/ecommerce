#  www/[ec_url_concat [ec_url] /admin]/products/upload-utilities.tcl
ad_page_contract {
  Upload utilites admin page.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id upload-utilities.tcl,v 3.1.6.1 2000/07/22 07:57:46 ron Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
}

ad_require_permission [ad_conn package_id] admin

doc_body_append "[ad_admin_header "Upload Utilities"]

<h2>Upload Utilities</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index.tcl" "Products"] "Upload Utilities"]

<hr>

There are three utilities provided with the ecommerce module that can
help you load you catalog data into the database:

<ul>
<li><a href=\"upload\">Product Loader</a>
<li><a href=\"extras-upload\">Product Extras Loader</a>
<li><a href=\"categories-upload\">Product Category Map Loader</a>
</ul>

<p>The product loader uploads a CSV file that contains one line per product
in your catalog.  Each line has fields corresponding to a subset of the
columns in the ec_products table.  The first line of the CSV file is a
header that defines which fields are being loaded and the order that
they appear in the CSV file.  The remaining lines contain the product
data.

<p>The product extras loader is similar to the product loader except it
loads data into ec_custom_product_field_values, the table which contains
the values for each product of the custom fields you've added.
The file format is
also similar to that of the product data CSV file.

<p><b>Note:</b>You must load the products and define the extra fields
you wish to use before you can load the product extras.

<p>The product category map loader creates the mappings between products
and categories and products and subcategories (specifically, it inserts
rows into ec_category_product_map and ec_subcategory_product_map.)  The
CSV file you create for uploading should consist of product id and
category or subcategory names, one per row.  This program attempts to be
smart by using the SQL like function to resolve close matches between
categories listed in the CSV file and those known in the database.

<p><b>Note:</b>You must create the categories and subcategories before
you can use the product category map loader.

[ad_admin_footer]
"
