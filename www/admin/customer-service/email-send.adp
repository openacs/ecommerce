<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

   @early_message;noquote@
<if @email_to_use@ not nil>

<!-- this form should use the standard spell checker tool instead of
 the ecommerce one -->
 <form name=email_form method=post action=../tools/spell>
  @export_form_vars_html;noquote@
   <table>
    <tr><td align=right><b>From</td><td>@customer_service_email@</td></tr>
    <tr><td align=right><b>To</td><td>@email_to_use@</td></tr>
    <tr><td align=right><b>Cc</td><td><input type=text name=cc_to size=30></td></tr>
    <tr><td align=right><b>Bcc</td><td><input type=text name=bcc_to size=30></td></tr>
    <tr><td align=right><b>Subject</td><td><input type=text name=subject size=30></td></tr>
    <tr><td align=right><b>Message</td><td><textarea wrap name=message rows=10 cols=50></textarea></td></tr>
    <tr><td align=right><b>Canned Responses</td><td>@email_form_message@</td></tr>
   </table>
  <br>
   <center>
   <input type=submit value="Send">
  </center>
 </form>
</if>
