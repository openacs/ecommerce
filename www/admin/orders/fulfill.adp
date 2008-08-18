<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<form name=fulfillment_form method=post action=fulfill-2>

<if @shipping_method@ eq "no shipping">
  <p>  Fulfillment date (required): @shipping_time_html;noquote@</p>
</if><else>
<p>
  Enter the following if relevant:
</p>

<table>
<tr>
<td>Shipment date (required):</td>
<td>@shipping_time_html;noquote@</td>
</tr>
<tr>
<td>Expected arrival date:</td>
<td>@expected_arrival_time;noquote@</td>
</tr>
<tr>
<td>Carrier</td>
<td>
<select name=carrier>
<option value="">select a carrier</option>
<option value="FedEx">FedEx</option>
<option value="UPS Ground">UPS Ground</option>
<option value="UPS Air">UPS Air</option>
<option value="US Priority">US Priority</option>
<option value="USPS">USPS</option>
</select>

Other:
<input type=text name=carrier_other size=10>
</td>
</tr>
<tr>
<td>Tracking Number</td>
<td><input type=text name=tracking_number size=20></td>
</tr>
</table>

</else>

<center>
<input type=submit value="Continue">
</center>
</form>
