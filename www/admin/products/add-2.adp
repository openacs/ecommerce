<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<form method=post action=add-3>
  @export_form_vars_html;noquote@


<h3>Select a template to use when displaying this product.</h3>
<p> If none is selected, the product will be displayed with the system default template.<br>
 @template_html;noquote@
<center>
<input type=submit value="Submit">
</center>
</form>


