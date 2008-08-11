<master>
  <property name="doc(title)">@title@</property>
  <property name="context">@context;noquote@</property>
  <property name="signatory">@ec_system_owner;noquote@</property>

  <property name="current_location">shopping-cart</property>

<include src="/packages/ecommerce/lib/toolbar">
<include src="/packages/ecommerce/lib/searchbar">

<ul>
  <li>Shipping Date: @pretty_ship_date@</li>
  <li>Carrier: @carrier@</li>
  <li>Tracking Number: @tracking_number@</li>
</ul>

<h4>Information from @carrier@</h4>

<blockquote>
  @carrier_info@
</blockquote>
