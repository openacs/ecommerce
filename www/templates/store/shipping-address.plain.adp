<ec_header>Enter Your Address</ec_header>
<ec_navbar>checkout address</ec_navbar>
<h2>Enter Your Shipping Address</h2>

<form method=post action=shipping-address-2.tcl>
<blockquote>
<table>
<tr>
 <td>Name</td>
 <td><input type=text name=attn size=30 value=<%= "\"$user_name_with_quotes_escaped\"" %>></td>
</tr>
<tr>
 <td>Address</td>
 <td><input type=text name=line1 size=40></td>
</tr>
<tr>
 <td>2nd line (optional)</td>
 <td><input type=text name=line2 size=40></td>
</tr>
<tr>
 <td>City</font></td>
 <td><input type=text name=city size=20> &nbsp;State <%= $state_widget %></td>
</tr>
<tr>
 <td>Zip</td>
 <td><input type=text maxlength=5 name=zip_code size=6></td>
</tr>
<tr>
 <td>Phone</td>
 <td><input type=text name=phone size=20 maxlength=20> <input type=radio name=phone_time value=D CHECKED> day &nbsp;&nbsp;&nbsp;<input type=radio name=phone_time value=E> evening</td>
</tr>
</table>
</blockquote>
<p>
<center>
<input type=submit value="Continue">
</center>
</form>

<ec_footer></ec_footer>



