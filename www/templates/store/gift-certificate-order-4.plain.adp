<ec_header>Please Confirm Your Gift Certificate Order</ec_header>

<ec_header_image></ec_header_image><br clear=all>

<h2>Please Confirm Your Gift Certificate Order</h2>

<blockquote>

<form method=post action="gift-certificate-finalize-order">
<%= $hidden_form_variables %>
<b>Push Submit to send us your order!</b>
<input type=submit value="Submit">

<blockquote>

<table>
<tr><td valign=top>Your email address:</td><td><%= $user_email %><br><br></td></tr>

<tr><td colspan=2><font size=+1>Your Gift Certificate Order:</font></td></tr>
<%= $to_row %>
<%= $from_row %>
<%= $message_row %>
<tr><td valign=top><b>Will be sent to:</b></td><td><%= $recipient_email %><br><br></td></tr>
<tr><td><b>Subtotal:</b></td><td><%= $formatted_amount %></td></tr>
<tr><td><b>Shipping:</b></td><td><%= $zero_in_the_correct_currency %></td></tr>
<tr><td><b>Tax:</b></td><td><%= $zero_in_the_correct_currency %></td></tr>
<tr><td><b>-----------</b></td><td><b>-----------</b></td></tr>
<tr><td><b>Total Due:</b></td><td><%= $formatted_amount %></td></tr>

</table>
</blockquote>

<b>Push Submit to send us your order!</b>
<input type=submit value="Submit">
</form>

</blockquote>
<ec_footer></ec_footer>
