<ec_header>Completing Your Order</ec_header>
<ec_navbar>checkout {Select Address}</ec_navbar>
<!-- <ec_header_image></ec_header_image><br clear=all> -->

<h2>Completing Your Order</h2>

<blockquote>

<p>

<b>Please enter your shipping address.</b> <%= $saved_addresses %>
<ul>
<li><a href="shipping-address">Enter a new U.S. address <%= [ec_decode $shipping_unavail_p 0 "as your shipping address " ""] %></a>
<li><a href="shipping-address-international">Enter a new international address for anywhere else in the world</a>
</ul>

</blockquote>
<ec_footer></ec_footer>
