<master>
  <property name="title">Your Shipment</property>
  <property name="context_bar">@context_bar@</property>
  <property name="signatory">@ec_system_owner@</property>

  <include src="toolbar" current_location="shopping-cart">

<ul>
  <li>Shipping Date: @pretty_ship_date@</li>
  <li>Carrier: @carrier@</li>
  <li>Tracking Number: @tracking_number@</li>
</ul>

<h4>Information from @carrier@</h4>

<blockquote>
  @carrier_info@
</blockquote>
