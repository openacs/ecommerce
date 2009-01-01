<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<h3>Overview</h3>
<ul>
  <li>Shipping Date: @pretty_ship_date@</li>
  <li>Carrier: @carrier@</li>
  <li>Tracking Number: @tracking_number@</li>
</ul>

<h4>Information from @carrier_name@</h4>

<blockquote>
@carrier_tracking_info;noquote@
</blockquote>
