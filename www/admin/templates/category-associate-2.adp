<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<p>This will cause @category_name@ to no longer be associated with its previous template, @old_template@.  Continue?</p>

<form method=post action=category-associate-2>
@export_vars_html;noquote@
@export_form_vars_html;noquote@
@hidden_input_html;noquote@
<center>
  <input type=submit value="Yes">
</center>
</form>
