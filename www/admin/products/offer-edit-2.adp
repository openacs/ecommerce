<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<table>
<tr>
<td>Retailer:</td>
<td>@retailer_name_select_html;noquote@</td>
</tr>
<tr>
<td>Price:</td>
<td>@price_html;noquote@</td>
</tr>
<tr>
<td>Shipping:</td>
<td>@shipping_html;noquote@</td>
</tr>
<tr>
<td>Stock Status:</td>
<td>@stock_status_html;noquote@</td>
</tr>
<tr>
<td>Offer Begins</td>
<td>@offer_begins_html;noquote@</td>
</tr>
<tr>
<td>Offer Expires</td>
<td>@offer_ends_html;noquote@</td>
</tr>
<if @special_offer_p;literal@ true>
<tr><td>Special Offer:</td><td>@special_offer_html;noquote@</td></tr>
</if>
</table>

<form method=post action=offer-edit-3>
@export_form_vars_html;noquote@
<center>
<input type=submit value="Confirm">
</center>
</form>

