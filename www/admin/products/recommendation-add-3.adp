<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<p>Please confirm your product recommendation:</p>

<blockquote>
<table cellpadding=10>
<tr>
<td>Product:</td>
<td>@product_name;noquote@</td>
</tr>
<tr>
<td>Recommended For:</td>
<td>@user_class_html@</td>
</tr>
<tr>
<td>Display Recommendation In:</td>
<td>@categorization_html;noquote@</td>
</tr>
<tr>
<td>Accompanying Text<br>(HTML format):</td>
<td>@recommendation_text@</td>
</tr>
</table>
</blockquote>

<form method=post action="recommendation-add-4">
@export_form_vars_html;noquote@
<center>
<input type=submit value="Confirm">
</center>
</form>
