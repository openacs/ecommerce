<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<form method=post action=category-delete-2>

<p>Please confirm that you wish to delete the category @category_name@.  Please also note the following:</p>
<ul>
 <li>This will delete all subcategories and subsubcategories of the category <tt>@category_name@</tt>.</li>
 <li>This will not delete the products in this category (if any).  However, it will cause them to no longer be associated with this category.</li>
 <li>This will not delete the templates associated with this category (if any).  However, it will cause them to no longer be associated with this category.</li>
</ul>

 <center>
  <input type=submit value="Confirm">
 </center>
</form>
