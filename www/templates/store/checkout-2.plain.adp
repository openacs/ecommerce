<ec_header>Completing Your Order</ec_header>

<ec_navbar>checkout {$checkout_step}</ec_navbar>

<h2>Check Your Order</h2>

<ol>

<b><li>Verify the items you desire</b>

<p>

Please verify that the items and quantities shown below are correct. Put a 0 (zero) in the
Quantity field to remove a particular item from your order. 

<form method=post action=<%= "\"$form_action\"" %>>

<table>
<tr>
 <td>Quantity</td>
 <td> </td>
</tr>
<%= $rows_of_items %>
</table>

<p>

<%= $tax_exempt_options %>

</ol>

<center>
<input type=submit value="Continue">
</center>

</form>

<ec_footer></ec_footer>
