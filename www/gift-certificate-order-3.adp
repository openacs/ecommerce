<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
  <property name="signatory">@ec_system_owner;noquote@</property>

  <property name="show_toolbar_t">t</property>
  <property name="current_location">gift-certificate</property>

<form method=post action="gift-certificate-order-4">
  @hidden_form_variables;noquote@
  <blockquote>
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
    </table>
  </blockquote>
  <center>
    <input type="submit" value="Continue">
  </center>
</form>
