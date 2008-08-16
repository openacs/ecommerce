<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<form method=post action="recommendation-add-3">
@export_form_vars_html;noquote@
<table>
<tr>
<td>Product:</td>
<td>@product_name;noquote@</td>
</tr>
<tr>
<td>Recommended For:</td>
<td>@recommended_for_html;noquote@</td>
</tr>
<tr>
<td>Display Recommendation In:</td>
<td>@display_in_html;noquote@</td>
</tr>
<tr>
<td>Accompanying Text<br>(HTML format):</td>
<td><textarea wrap name=recommendation_text rows=6 cols=40></textarea></td>
</tr>
</table>

<center>
<input type=submit value="Submit">
</center>
</form>
