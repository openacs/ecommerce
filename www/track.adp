<master>
  <property name="title">Your Shipment</property>
  <property name="context_bar">@context_bar;noquote@</property>
  <property name="signatory">@ec_system_owner;noquote@</property>

  <property name="show_toolbar_p">t</property>
  <property name="current_location">shopping-cart</property>

<ul>
  <li>Shipping Date: @pretty_ship_date@</li>
  <li>Carrier: @carrier@</li>
  <li>Tracking Number: @tracking_number@</li>
</ul>

<h4>Information from @carrier@</h4>

<blockquote>
  @carrier_info@
</blockquote>
