<master src="default-ec-master">
<property name="title">Payment Info</property>

<h2>Payment Info</h2>

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
