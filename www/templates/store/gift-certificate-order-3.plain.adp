<ec_header>Payment Info</ec_header>

<ec_header_image></ec_header_image><br clear=all>

<h2>Payment Info</h2>

<form method=post action="gift-certificate-order-4">
<%= $hidden_form_variables %>

<blockquote>

<table>
<tr>
<td>Credit card number:</td>
<td><input type=text name=creditcard_number size=17></td>
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
<td><input type=text name=billing_zip_code value=<%= "\"$zip_code\"" %> size=5></td>
</tr>
</table>
</blockquote>

<center>
<input type=submit value="Continue">
</center>

</form>
<ec_footer></ec_footer>
