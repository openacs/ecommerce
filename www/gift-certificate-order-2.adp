<master>
  <property name="title">Your Gift Certificate Order</property>
  <property name="context_bar">@context_bar@</property>
  <property name="signatory">@ec_system_owner@</property>

  <include src="toolbar" current_location="gift-certificate">

<form method="post" action="gift-certificate-billing">
  <ol>
    <li>
      <table border="0" cellspacing="0" cellpadding="0">
	<tr>
	  <td>To: (optional)</td>
	  <td>&nbsp;</td>
	  <td><input type="text" name="certificate_to" size="30"></td>
	</tr>
	<tr>
	  <td>From: (optional)</td>
	  <td>&nbsp;</td>
	  <td><input type="text" name="certificate_from" size="30"></td>
	</tr>
      </table>
    </li>
    <li>
      <p>Please enter the message you want to appear on the gift certificate: (optional)</p>
	 <textarea wrap name="certificate_message" rows="4" cols="50"></textarea>
      <p>(maximum 200 characters)</p>
    </li>
    <li>
      <p>Gift certificate amount:
      <input type="text" name="amount" size="4"> (in @currency@, between @minimum_amount@ and @maximum_amount@)</p>
    </li>
    <li>
      <p>Recipient's email address: <input type="text" name="recipient_email" size="50"></input></p>
    </li>
  </ol>
  <center>
    <input type="submit" value="Continue">
  </center>
</form>
