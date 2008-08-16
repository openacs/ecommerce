<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<p>Please enter a new domestic address or a new international address.  
All future shipments for this order will go to this address.</p>

<p>New domestic address:</p>
<blockquote>
  <form method=post action=address-add-2>
@export_domestic_form_vars_html;noquote@
<table>
  <tr>
<td>Name</td>
<td><input type=text name=attn size=30 value="@user_name@"></td>
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
<td><input type=text name=city size=20> &nbsp;State @state_widget_html;noquote@</td>
  </tr>
  <tr>
<td>Zip</td>
<td><input type=text maxlength=5 name=zip_code size=5></td>
  </tr>
  <tr>
<td>Phone</td>
<td><input type=text name=phone size=20 maxlength=20> <input type=radio name=phone_time value=d CHECKED> day &nbsp;&nbsp;&nbsp;
<input type=radio name=phone_time value=e> evening</td>
  </tr>
</table>
<center>
  <input type=submit value="Continue">
</center>
  </form>
</blockquote>

<p>New international address:</p>

<blockquote>
  <form method=post action=address-add-2>
@export_international_form_vars;noquote@
 <table>
   <tr>
 <td>Name</td>
 <td><input type=text name=attn size=30 value="@user_name@"></td>
   </tr>
   <tr>
 <td>Address</td>
 <td><input type=text name=line1 size=50></td>
   </tr>
   <tr>
 <td>2nd line (optional)</td>
 <td><input type=text name=line2 size=50></td>
   </tr>
   <tr>
 <td>City</font></td>
 <td><input type=text name=city size=20></td>
   </tr>
   <tr>
 <td>Province or Region</td>
 <td><input type=text name=full_state_name size=15></td>
   </tr>
   <tr>
 <td>Postal Code</td>
 <td><input type=text maxlength=10 name=zip_code size=10></td>
   </tr>
   <tr>
 <td>Country</td>
 <td>@country_widget_html;noqute@</td>
   </tr>
   <tr>
 <td>Phone</td>
 <td><input type=text name=phone size=20 maxlength=20> <input type=radio name=phone_time value=d CHECKED> day &nbsp;&nbsp;&nbsp;
 <input type=radio name=phone_time value=e> evening</td>
   </tr>
 </table>
 <center>
   <input type=submit value="Continue">
 </center>
   </form>
 </blockquote>
