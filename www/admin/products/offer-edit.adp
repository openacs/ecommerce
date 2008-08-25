<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<form method=post action=offer-edit-2>
@export_form_vars_html;noquote@

<table>
<tr>
<td>
Retailer
</td>
<td>
<select name=retailer_id>
<option value="">Pick One
</select>
</td>
</tr>
<tr>
<td>Price</td>
<td><input type=text name=price size=6 value="@price@"> (in @currency@)</td>
</tr>
<tr>
<td>Shipping</td>
<td><input type=text name=shipping size=6 value="@shipping@"> (in @currency@) 
&nbsp;&nbsp;<b>or</b>&nbsp;&nbsp;
<input type=checkbox name=shipping_unavailable_p value="t" <if
@shipping_unavailable_p@ true>checked</if>>
Pick Up only
</td>
</tr>
<tr>
<td>Stock Status</td>
<td>@stock_status_html;noquote@</td>
</tr>
<tr>
<td>Offer Begins</td>
<td>@offer_begins_html;noquote@</td>
</tr>
<tr>
<td>Offer Expires</td>
<td>@offer_expires_html;noquote@</td>
</tr> 
<tr>
<td colspan=2>Is this a Special Offer?
<input type=radio name=special_offer_p value="t" <if
@special_offer_p@ true>checked</if>> Yes &nbsp; 
<input type=radio name=special_offer_p value="f" <if
@special_offer_p@ false>checked</if>> No
</td>
</tr>
<tr>
<td>If yes, elaborate:</td>
<td><textarea wrap name=special_offer_html rows=2 cols=40>@special_offer_html@</textarea></td>
</tr>
</table>

<center>
<input type=submit value="Edit">
</center>

</form>
