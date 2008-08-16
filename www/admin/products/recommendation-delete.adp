<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<p>Are you sure that you want to delete this recommendation of 
@product_name;noquote@ (to @user_class_description@)?</p>

<form method=GET action="recommendation-delete-2">
@export_form_vars_html;noquote@
<center>
<input type=submit value="Yes, I am sure">
</center>
</form>

