<ec_header>Your Gift Certificate Order</ec_header>
<ec_header_image></ec_header_image><br clear=all>

<h2>Your Gift Certificate Order</h2>

<form method=post action=gift-certificate-order-3>

<ol>
<li><table border=0 cellspacing=0 cellpadding=0>
<tr><td>To: (optional) </td><td><input type=text name=certificate_to size=15></td></tr>
<tr><td>From: (optional) </td><td><input type=text name=certificate_from size=15></td></tr>
</table>
<p>
<li>Please enter the message you want to appear on the gift
certificate: (optional)<br>
(maximum 200 characters)
<br>
<textarea wrap name=certificate_message rows=4 cols=50></textarea>
<p>
<li>Gift certificate amount:
<input type=text name=amount size=4> (in <%= $currency %>)<br>
(between <%= $minimum_amount %> and <%= $maximum_amount %>)
<p>
<li>Recipient's email address:
<input type=text name=recipient_email size=30>
</ol>

<center>
<input type=submit value="Continue">
</center>

<ec_footer></ec_footer>
