<ec_header>Enter Your Address</ec_header>
<ec_navbar>checkout {select address}</ec_navbar>
<h2>Enter Your Shipping Address</h2>

<form method=post action=shipping-address-2.tcl>
<input type="hidden" name="address_id" value=<%= "\"$address_id\"" %>>
<blockquote>
<table>
<tr>
 <td>Name</td>
 <td><input type=text name=attn size=30 value=<%= "\"$user_name_with_quotes_escaped\"" %>></td>
</tr>
<tr>
 <td>Address</td>
 <td><input type=text name=line1 size=40 value=<%= "\"$line1\"" %>></td>
</tr>
<tr>
 <td>2nd line (optional)</td>
 <td><input type=text name=line2 size=40 value=<%= "\"$line2\"" %>></td>
</tr>
<tr>
 <td>City</font></td>
 <td><input type=text name=city size=20 value=<%= "\"$city\"" %>> &nbsp;State <%= $state_widget %></td>
</tr>
<tr>
 <td>Zip</td>
 <td><input type=text maxlength=5 name=zip_code size=6 value=<%= "\"$zip_code\"" %>></td>
</tr>
<tr>
 <td>Phone</td>
 <td><input type=text name=phone size=20 maxlength=20 value=<%= "\"$phone\"" %>> <input type=radio name=phone_time value=D 
 <%= 
   if { ![info exists phone_time] || $phone_time == "D" } {
     ns_puts "CHECKED"
   } %>> day &nbsp;&nbsp;&nbsp;<input type=radio name=phone_time value=E
 <%= 
   if { $phone_time == "E" } {
     ns_puts "CHECKED"
   } %>> evening</td>
</tr>
</table>
</blockquote>
<p>
<center>
<input type=submit value="Continue">
</center>
</form>

<ec_footer></ec_footer>

