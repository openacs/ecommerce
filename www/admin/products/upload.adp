<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<form enctype="multipart/form-data" action="upload-2" method="post">
Data Filename <input name="csv_file" type="file">
<br>
<input type="radio" name="file_type" value="csv" checked>CSV format<br>
<input type="radio" name="file_type" value="tab">Tab Delimited format<br>
<input type="radio" name="file_type" value="delim">Delimited by: <input name="delimiter" value=" " type="text"> (single character).<br>
 <br>
<center>
<input type="submit" value="Upload">
</center>
</form>

<p>

<b>Notes:</b>

<blockquote>
<p>

This page uploads a data file containing product information into the database.  The file format should be:
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
@doc_body;noquote@
</pre>
</blockquote>
<p>
Note: <code>@undesirable_cols_html;noquote@</code> are set 
automatically and should not appear in the data file. Also, note that <tt>product_name</tt> is not required for
parts that are already existing in the system; which eases the price updating process, since you can get by with a file
with only two columns: <tt>sku</tt> and <tt>price</tt>.
</p>
</blockquote>
</blockquote>
<p>About search_keywords: Data from product_name, one_line_description, and detailed_description 
are automatically included in product searches. No need to repeat that information in search_keywords.</p>
