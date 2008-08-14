#  www/[ec_url_concat [ec_url] /admin]/products/upload.tcl
ad_page_contract {
  This page uploads a data file containing store-specific products into
  the catalog. The file format should be:

  one product reference per line
} {
}

ad_require_permission [ad_conn package_id] admin
set title "Import Vendors Products"
doc_body_append "[ad_admin_header $title]

<h2>$title</h2>

[ad_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index.tcl" "Products"] $title]

<hr>

<blockquote>

<form enctype=\"multipart/form-data\" action=\"upload-vendor-imports-2\" method=\"post\">
Data Filename <input name=\"csv_file\" type=\"file\">
<br>
[ecds_vendor_choose_widget]
 <br>
<center>
<input type=\"submit\" value=\"Upload\">
</center>
</form>

<b>Notes:</b>

<p>

This page uploads a data file containing vendor product references into the database, there should only be one reference per line.
"
doc_body_append "
[ad_admin_footer]
"
