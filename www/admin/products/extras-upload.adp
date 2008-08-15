<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<blockquote>

<form enctype="multipart/form-data" action="extras-upload-2" method="post">
Data Filename <input name="csv_file" type="file">
<br>
<input type="radio" name="file_type" value="csv" checked>CSV format<br>
<input type="radio" name="file_type" value="tab">Tab Delimited format<br>
<input type="radio" name="file_type" value="delim">Delimited by: <input name="delimiter" value=" " type="text"> (single character).<br>
 <br>
<center>
<input type=submit value="Upload">
</center>
</form>
</blockquote>

<p><b>Notes:</b></p>


<p>
This page uploads a data file containing product information into the database.  The file format should be:
</p>
<blockquote>
<code>field_name_1, field_name_2, ... field_name_n<br>
value_1, value_2, ... value_n</code>
</blockquote>
<p>
where the first line contains the actual names of the columns in ec_custom_product_field_values and the remaining lines contain
the values for the specified fields, one line per product.
</p><p>
Legal values for field names are the columns in ec_custom_product_field_values
(which are set by you when you add custom database fields):
</p>
<blockquote>
<pre>
@doc_body;noquote@
</pre>
</blockquote>
<p>
Note: Some of these fields may be inactive, in which case there
might be no good reason for you to include them in the upload.
Additionally, <code>@undesirable_cols_html;noquote@</code> are set 
automatically and should not appear in the CSV file.
</p>
