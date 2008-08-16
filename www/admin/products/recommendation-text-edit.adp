<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<p>Edit text for the recommendation of $product_name:</p>

<form method=GET action="recommendation-text-edit-2">
@export_form_vars_html;noquote@
<textarea name=recommendation_text rows=10 cols=70 wrap=soft>
@recommendation_text@
</textarea>
<br>
<center>
<input type=submit value="Update">
</center>
</form>


