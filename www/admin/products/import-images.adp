<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>

<property name="show_toolbar_p">t</property>

<h2>@title@</h2>

<blockquote>

<form enctype="multipart/form-data" action="import-images-2" method="post">
Data Filename <input name="csv_file" type="file">
<br>
<input type="radio" name="file_type" value="csv" checked>CSV format<br>
<input type="radio" name="file_type" value="tab">Tab Delimited format<br>
<input type="radio" name="file_type" value="delim">Delimited by: <input name="delimiter" value=" " type="text"> (single character).<br>
 <br>

<input type="submit" value="Import">

</form>

</blockquote>

<p><b>Notes:</b></p>

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
