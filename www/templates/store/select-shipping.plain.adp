<ec_header>Completing Your Order</ec_header>

<ec_navbar>checkout {$checkout_step}</ec_navbar>

<h2>Select Shipping Method</h2>

<ol>

<form method=post action=<%= "\"$form_action\"" %>>

<%= $shipping_options %>

<p>

<%= $tax_exempt_options %>

</ol>

<center>
<input type=submit value="Continue">
</center>

</form>

<ec_footer></ec_footer>
