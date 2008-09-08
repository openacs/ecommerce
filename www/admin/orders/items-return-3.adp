<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

    <form method=post action=items-return-4>
     @export_form_vars_html;noquote@

       <p>Total refund amount: @total_amount_to_refund@ (price: @total_price_to_refund_html@, shipping: @total_shipping_to_refund_html@, tax: @total_tax_to_refund_html@)</p>
       <ul>
        <li>@certificate_amount_to_reinstate_html@ will be reinstated in gift certificates.</li>
        <li>@cash_amount_to_refund_html@ will be refunded to the customer's credit card.</li>
      </ul>

<if @request_creditcard@ true>
    <p>Please re-enter the credit card number of the card used for this order:</p>
    <table border=0 cellspacing=0 cellpadding=10>
       <tr>
         <td><input type="hidden" name="creditcard_id" value="@creditcard_id@"></td>
         <td> @creditcard_widget_html;noquote@ </td>
         <td><input type="text" name="creditcard_number" size="21" maxlength="17"></td>
        
       </tr>
<if @ask_for_card_code@ true>
  <tr>
    <td align="right">Card Security Code (cvv2/cvc2/cid):</td>
    <td><input type="text" name="card_code" size="4" tabindex="42"</td>
  </tr>
</if>

	<tr>
	  <td>Ending in:</td>
	  <td>xxxxxxxxxxxx@creditcard_last_four@</td>
       </tr><tr>
         <td>Expires:</td>
         <td>@card_expiration@</td>
       </tr><tr>
         <td valign="top">Billing address:</td>
         <td>@billing_street@<br>
	     @billing_city@, @billing_state@ @billing_zip@<br>
	     @billing_country@</td>
       </tr>
       </table>
</if><else>
  @export_form_vars_2_html;noquote@
</else>
@export_form_vars_cc_type_html;noquote@
@export_form_vars_last_4_html;noquote@
  <center>
    <input type=submit value="Complete the Refund">
  </center>
</form>
