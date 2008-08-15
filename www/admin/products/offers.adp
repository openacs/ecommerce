<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<if @no_offers@ true>
<p>There are no current offers.</p>
</if><else>
<ul>
@offers_select_html;noquote@
</ul>
</else>
<p>

<h3>Add an Offer</h3>

<form method=post action=offer-add>
@export_product_id_html;noquote@
<table>
<tr>
<td>
Retailer
</td>
<td>
<select name=retailer_id>
<option value="">Pick One>
@retailer_select_html;noquote@
</select>
</td>
</tr>
<tr>
<td>Price</td>
<td><input type=text name=price size=6> (in @currency@)</td>
</tr>
<tr>
<td>Shipping</td>
<td><input type=text name=shipping size=6> (in @currency@) 
&nbsp;&nbsp;<b>or</b>&nbsp;&nbsp;
<input type=checkbox name=shipping_unavailable_p value="t">
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
<input type=radio name=special_offer_p value="t">Yes &nbsp; 
<input type=radio name=special_offer_p value="f" checked>No
</td>
</tr>
<tr>
<td>If yes, elaborate:</td>
<td><textarea wrap name=special_offer_html rows=2 cols=40></textarea></td>
</tr>
</table>
<br>
<center>
<input type=submit value="Add">
</center>
</form>

<br>
<h3>Non-Current or Deleted Offers</h3>

<if @no_non_current_offers@ true>
<p>There are no non-current or deleted offers.</p>
</if><else>
<ul>
@non_current_offers_select_html;noquote@
<ul>
</else>
