<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<p>Add the following new subsubcategory to $subcategory_name?</p>
<pre>
        @subsubcategory_name@

</pre>
<form method=post action=subsubcategory-add-2>
 @export_form_vars_html;noquote@
 <center>
  <input type=submit value="Yes">
 </center>
</form>
