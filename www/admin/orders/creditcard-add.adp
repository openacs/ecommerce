<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<p>Entering a new credit card will cause all future transactions
involving this order to use this credit card.  However, it will
not have any effect on transactions that are currently
underway. For example, if a transaction has been previously authorized
with a different credit card, that transaction will use the credit
card that is already associated with it (through authorization).
</p>

<p>
  @billing_address_html;noquote@
</p>
<form method="post" action="creditcard-add-2">
  <input type="hidden" name="address_id" value="@billing_address@"></input>
  @export_form_vars_html;noquote@
  <table>
 <tr>
  <td>Credit card number:</td>
  <td><input type="text" name="creditcard_number" size="21"></td>
 </tr>
 <tr>
  <td>Type:</td>
  <td>@credit_card_type_html;noquote@</td>
 </tr>
 <tr>
  <td>Expires:</td>
  <td>@credit_card_exp_html;noquote@</td>
 </tr>
 <tr>
  <td colspan="2">
   <center><input type="submit" value="Submit"></center>
  </td>
 </tr>
  </table>
</form>

