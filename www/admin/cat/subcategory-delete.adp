<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<form method=post action=subcategory-delete-2>
<p>Please confirm that you wish to delete the subcategory
@subcategory_name@ of category @category_name@.  Please also note the following:</p>
<ul>
  <li>This will delete all subsubcategories of the subcategory @subcategory_name@.</li>
  <li>This will not delete the products in this subcategory (if any).  However, it will cause them to no longer be associated with this subcategory.</li>
</ul>

<center>
  <input type=submit value="Confirm">
</center>
</form>
