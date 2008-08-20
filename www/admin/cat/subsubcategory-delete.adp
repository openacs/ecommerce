<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<form method=post action=subsubcategory-delete-2>
 @export_form_vars_html;noquote@
 <p>Please confirm that you wish to delete the subsubcategory @subsubcategory_name@.  This will not delete the products in this subsubcategory (if any).  However, it will cause them to no longer be associated with this subsubcategory.
 </p>
 <center>
  <input type=submit value="Confirm">
 </center>
</form>
