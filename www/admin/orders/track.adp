<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<h3>Overview</h3>

<form  method=post action=track-update.tcl>
@export_form_vars_html;noquote@
<ul>
  <li>Shipping Date: @pretty_ship_date@</li>
  <li>Carrier: @carrier_select_html;noquote@</li>
  <li>Tracking Number: <input type=text name=tracking_number value="@tracking_number@" size="25" /></li>
  <li>Expected Arrival Date: @expected_arrival_html;noquote@</li>
</ul>
<center>
<input type=submit value="Update" />
</center>

</form>

<h4>Information from @carrier_name@</h4>

<blockquote>
@carrier_tracking_info;noquote@
</blockquote>
