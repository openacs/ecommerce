<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<table cellpadding=10>
<tr>
<td>Product:</td>
<td>@product_name;noquote@</td>
</tr>
<tr>
<td>Recommended For:</td>
<td>@user_class_name_select_html;noquote@</td>
</tr>
<tr>
<td>Display Recommendation In:</td>
<td>@category_level_html;noquote@</td>
</tr>
<tr>
<td valign=top>Accompanying Text<br>(HTML format):</td>
<td valign=top>@recommendation_text@
<br>
(<a href="recommendation-text-edit?@export_url_rec_html;noquote@">edit</a>)
</td>
</tr>
</table>

<ul>
<li><a href="@audit_url_html;noquote@">Audit Trail</a></li>
<li><a href="recommendation-delete?@export_url_rec_html;noquote@">Delete</a>
</ul>

