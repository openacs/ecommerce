<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>
<p>Upload a data file containing vendor product references into the
database, there should only be one reference per line.  The system
will attempt to import referenced products from vendor's website based
on custom code built around <tt>ecds_import_product_from_vendor_site</tt>.</p>
<form enctype="multipart/form-data" action="upload-vendor-imports-2" method="post">
Data Filename <input name="csv_file" type="file">
<br>
@vendor_choose_widget_html;noquote@
<br>
<center>
<input type="submit" value="Upload">
</center>
</form>


