<master>
<property name="title">@page_title@</property>
<property name="context_bar">@context_bar;noquote@</property>

<property name="show_toolbar_p">t</property>

<h2>@page_title@</h2>

<blockquote>

<form enctype=multipart/form-data action=categories-upload-2 method=post>
CSV Filename <input name=csv_file type=file>
<p>
<center>
<input type=submit value=Upload>
</center>
</form>

<p><b>Notes:</b></p>

<blockquote>


<p>This page uploads a CSV file containing product category names and creates product category mappings.</p>

<p>The file format should made up of lines where the first column is a sku and all subsequent columns are names 
which match one of a subsubcategory, a subcategory or a category (matched in that order). Category
matching is case insensitive.</p>

<p>If a subcategory match is found, the product is placed into the matching subcategory as well as the parent category  
of the matching subcategory. If no match is found for a product, no mapping entry is made.</p>

</blockquote>
</blockquote>
