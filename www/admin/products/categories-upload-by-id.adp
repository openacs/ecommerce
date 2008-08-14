<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<blockquote>

<form enctype="multipart/form-data" action="categories-upload-by-id-2" method="post">
Data Filename <input name="csv_file" type="file">
<br>
<input type="radio" name="file_type" value="csv" checked>CSV format<br>
<input type="radio" name="file_type" value="tab">Tab Delimited format<br>
<input type="radio" name="file_type" value="delim">Delimited by: <input name="delimiter" value=" " type="text"> (single character).<br>
<p>
<center>
<input type="submit" value="Upload">
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
