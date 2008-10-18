<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>

These utilities help you load catalog data into the database:

<ul>
<li><p><a href="upload">Product Loader</a>
 uploads a data file that contains one line per product
 in your catalog.  Each line has fields corresponding to a subset of the
 columns in the <tt>ec_products</tt> table.  The first line of the data file is a
 header that defines which fields are being loaded and the order that
 they appear in the data file.  The remaining lines contain the product
 data.
</p></li>
<li><p><a href="extras-upload">Product Extras Loader</a>
 is similar to the product loader except it
 loads data into <tt>ec_custom_product_field_values</tt>, the table which contains
 the values for each product of the custom fields you have added.
 The file format resembles the products import data file format.
</p></li>
<li><p><a href="categories-upload">Product Category Map Loader By Name-Matching</a>
 creates the mappings between products in <tt>ec_products</tt> table
 and categories in <tt>ec_categories</tt>, <tt>ec_subcategories</tt>, and <tt>ec_subsubcategories</tt> tables 
 by inserting rows into <tt>ec_category_product_map</tt> and <tt>ec_subcategory_product_map</tt>.)  The
 data file you create for uploading should consist of product sku and
 category or subcategory names, one per row.  This process attempts to be
 smart by using the SQL "LIKE" function to resolve close matches between
 categories listed in the data file and those known in the database.
</p></li>
<li><p><a href="categories-upload-by-id">Product Category Map Loader By Index Matching</a>
 creates the product-categories mappings by finding exact matches to the
 category tables' indexes <tt>category_id</tt>, <tt>subcategory_id</tt>, <tt>subsubcategory_id</tt>.
</p></li>

<li><p>
 <a href="import-images">Bulk Product Image Loader</a> imports product images for existing
 products, and creates thumbnails for them.  
 Place product images in a set of directories accessible by this server. Then use this utility
 to upload a file that maps product <tt>sku</tt> to the location of the product images
 <tt>full_imagepathname</tt>.
</p></li>
<li><p>
<a href="upload-vendor-imports">Upload Vendor Imports</a> imports
products from a vendor website according to previously defined procedures: ecds_vendor_procs using references in a file.
</p></li>
<li><p>
<a href="vendor-imports-add-update">Vendor Imports Add/Update</a> adds or imports products from a vendor website via a form.
</p></li>
</ul>
<p>Note:</p>
<ul>
<li>Products need to be loaded and their extra fields need to be defined before 
  loading product extras.</li>
<li>Categories and subcategories need to be created before using 
  a Product Category Map Loader.</li>
<li>There may be a peak load condition on the server for an extended period 
  when bulk loading of product images create product thumbnails (optional feature).
</li></ul>

