<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<table>
<tr>
<td>Sale Price</td>
<td>@sale_price_html;noquote@</td>
</tr>
<tr>
<td>Name</td>
<td>@sale_name@</td>
</tr>
<tr>
<td>Sale Begins</td>
<td>@sale_begins_html;noquote@</td>
</tr>
<tr>
<td>Sale Ends</td>
<td>@sale_ends_html;noquote@</td>
</tr>
<tr>
<td>Offer Code</td>
<td>@offer_code_html;noquote@</td>
</tr>
</table>

<form method=post action=sale-price-add-2>
@export_form_vars_html;noquote@
<input type=hidden name=sale_begins value="@form_sale_begins_html;noquote@">
<input type=hidden name=sale_ends value="@form_sale_ends_html;noquote@">
<center>
<input type=submit value="Confirm">
</center>

</form>
