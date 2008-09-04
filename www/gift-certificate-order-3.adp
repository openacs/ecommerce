<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
  <property name="signatory">@ec_system_owner;noquote@</property>

  <property name="show_toolbar_t">t</property>
  <property name="current_location">gift-certificate</property>

<form method=post action="gift-certificate-order-4">
  @hidden_form_variables;noquote@

    <table>
      <tr>
	<td>Credit card number:</td>
	<td><input type="text" name="creditcard_number" size="21"></td>
      </tr>
      <tr>
	<td>Type:</td>
	<td>@ec_creditcard_widget;noquote@</td>
      </tr>
      <tr>
	<td>Expires:</td>
	<td>@ec_expires_widget;noquote@</td>
      </tr>
<if @ask_for_card_code@ true>
      <tr>
	<td>Credit card security digits (cvv2/cvc2/cid):</td>
	<td><input type="text" name="card_code" size="4"></td>
      </tr>
</if>
    </table>

  <center>
    <input type="submit" value="Continue">
  </center>
</form>
