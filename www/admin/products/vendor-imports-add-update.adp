<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>
<p>Enter vendor product references into this form to add to the product catalog.
The system will attempt to import referenced products from vendor's website based
on custom code built around <tt>ecds_import_product_from_vendor_site</tt>.</p>
<form enctype="multipart/form-data" action="vendor-imports-add-update-2" method="post">
Vendor SKUs <textarea wrap rows=60 cols=60 name=vendor_sku_string></textarea>
<br>
@vendor_choose_widget_html;noquote@
<br>
<center>
<input type="submit" value="Add / Update">
</center>
</form>


