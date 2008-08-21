<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<p><b>Customer:</b> @customer_info_html;noquote@</p>
<b>Gift Certificate Account Balance:</b> @gift_cert_account_bal_html;noquote@</p>
<p><b>Grant a gift certificate</b></p>
<form method=post action=gift-certificate-add>
@export_form_vars_html;noquote@
 <table>
  <tr>
    <td>Amount</td>
    <td><input type=text name=amount size=5> ()</td>
    <td rowspan=2><input type=submit value=\"Grant\"></td>
  </tr>
  <tr>
    <td>Expires</td>
    <td>@gc_expires_widget_html;noquote</td>
  </tr>
 </table>
</form>
@gift_certs_for_users_html;noquote@

