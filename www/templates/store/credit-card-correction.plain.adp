<ec_header>Sorry, We Were Unable to Authorize Your Credit Card</ec_header>

<ec_header_image></ec_header_image><br clear=all>

<h2>Sorry, We Were Unable to Authorize Your Credit Card</h2>

<blockquote>

<p>
At this time we are unable to receive authorization to charge your
credit card.  Please check the number and the expiration date and
try again or use a different credit card.

<form method=post action=credit-card-correction-2>

<table>
<tr>
<td>Credit card number:</td>
<td><input type=text name=creditcard_number size=17 value=<%= "\"$creditcard_number\"" %>></td>
</tr>
<tr>
<td>Type:</td>
<td><%= $ec_creditcard_widget %></td>
</tr>
<tr>
<td>Expires:</td>
<td><%= $ec_expires_widget %></td>
<tr>
<td>Billing zip code:</td>
<td><input type=text name=billing_zip_code value=<%= "\"$billing_zip_code\"" %> size=5></td>
</tr>
</table>

<p>

<center>
<input type=submit value="Submit">
</center>
</form>

</blockquote>
<ec_footer></ec_footer>
