<master>
  <property name="title">Payment Info</property>
  <property name="context_bar">@context_bar;noquote@</property>
  <property name="signatory">@ec_system_owner;noquote@</property>

  <include src="toolbar" current_location="gift-certificate">

<form method=post action="gift-certificate-order-4">
  @hidden_form_variables@
  <blockquote>
    <table>
      <tr>
	<td>Credit card number:</td>
	<td><input type="text" name="creditcard_number" size="21"></td>
      </tr>
      <tr>
	<td>Type:</td>
	<td>@ec_creditcard_widget@</td>
      </tr>
      <tr>
	<td>Expires:</td>
	<td>@ec_expires_widget@</td>
      </tr>
    </table>
  </blockquote>
  <center>
    <input type="submit" value="Continue">
  </center>
</form>
