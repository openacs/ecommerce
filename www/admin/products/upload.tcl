#  www/[ec_url_concat [ec_url] /admin]/products/upload.tcl
ad_page_contract {
  This page uploads a CSV file containing store-specific products into
  the catalog. The file format should be:

    field_name_1, field_name_2, ... field_name_n
    value_1, value_2, ... value_n

  where the first line contains the actual names of the columns in
  ec_products and the remaining lines contain the values for the
  specified fields, one line per product.

  Legal values for field names are the columns in ec_products (see
  ecommerce/sql/ecommerce-create.sql for current column names):

    product_id (required)
    sku
    product_name (required)
    one_line_description:html
    detailed_description:html
    search_keywords
    price
    shipping
    shipping_additional
    weight
    dirname
    present_p
    active_p
    available_date
    announcements
    announcements_expire
    url
    template_id
    stock_status

  Note: dirname, creation_date, available_date, last_modified,
  last_modifying_user and modified_ip_address are set automatically
  and should not appear in the CSV file.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id upload.tcl,v 3.1.6.2 2000/07/22 07:57:46 ron Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
}

ad_require_permission [ad_conn package_id] admin

doc_body_append "[ad_admin_header "Upload Products"]

<h2>Upload Products</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index.tcl" "Products"] "Upload Products"]

<hr>

<blockquote>

<form enctype=multipart/form-data action=upload-2 method=post>
CSV Filename <input name=csv_file type=file>
<p>
<center>
<input type=submit value=Upload>
</center>
</form>

<p>

<b>Notes:</b>

<blockquote>
<p>

This page uploads a CSV file containing product information into the database.  The file format should be:
<p>
<blockquote>
<code>field_name_1, field_name_2, ... field_name_n<br>
value_1, value_2, ... value_n</code>
</blockquote>
<p>
where the first line contains the actual names of the columns in ec_products and the remaining lines contain
the values for the specified fields, one line per product.
<p>
Legal values for field names are the columns in ec_products:
<p>
<blockquote>
<pre>
"

set undesirable_cols [list "dirname" "creation_date" "available_date" "last_modified" "last_modifying_user" "modified_ip_address"]
set required_cols [list "product_id" "product_name"]


db_with_handle db {
  for {set i 0} {$i < [ns_column count $db ec_products]} {incr i} {
    set col_to_print [ns_column name $db ec_products $i]
    if { [lsearch -exact $undesirable_cols $col_to_print] == -1 } {
      doc_body_append "$col_to_print"
      if { [lsearch -exact $required_cols $col_to_print] != -1 } {
	doc_body_append " (required)"
      }
      doc_body_append "\n"
    }
  }
}

doc_body_append "</pre>
</blockquote>
<p>
Note: <code>[join $undesirable_cols ", "]</code> are set 
automatically and should not appear in the CSV file.

</blockquote>
</blockquote>

[ad_admin_footer]

"
