<ec_header>Your Shipment</ec_header>
<ec_navbar></ec_navbar>

<h2>Your Shipment</h2>

<ul>
<li>Shipping Date: <%= $pretty_ship_date %>
<li>Carrier: <%= $carrier %>
<li>Tracking Number: <%= $tracking_number %>
</ul>

<h4>Information from <%= $carrier %></h4>

<blockquote>
<%= $carrier_info %>
</blockquote>

<ec_footer></ec_footer>
