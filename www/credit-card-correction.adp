<master>
  <property name="title">Completing Your Order</property>
  <property name="context_bar">@context_bar@</property>
  <property name="signatory">@ec_system_owner@</property>

  <include src="checkout-progress" step="6">

<h2>Sorry, We Were Unable to Authorize Your Credit Card</h2>

  <blockquote>
  
  <p>At this time we are unable to receive authorization to charge
    your credit card.  Please check the number and the expiration
    date and try again or use a different credit card.</p>

  <table>
    <tr>
      <td>
	@formatted_address@
      </td>
      <td>
	<if @international_address@ eq 1>
	  <form method="post" action="address-international">
	    <input type="hidden" name="address_id" value="@address_id@"></input>
	    <input type="hidden" name="address_type" value="billing"></input>
	    <input type="submit" value="Edit"></input>
	  </form>
	</if>
	<else>
	  <form method="post" action="address">
	    <input type="hidden" name="address_id" value="@address_id@"></input>
	    <input type="hidden" name="address_type" value="billing"></input>
	    <input type="submit" value="Edit"></input>
	  </form>
	</else>
      </td>
      <td width="20%">
      </td>
      <td>
	<form method="post" action="credit-card-correction-2">
	  <input type="hidden" name="address_id" value="@address_id@"></input>
	  <table>
	    <tr>
	      <td>Credit card number:</td>
	      <td><input type="text" name="creditcard_number" size="21" value="@creditcard_number@"></td>
	    </tr>
	    <tr>
	      <td>Type:</td>
	      <td>@ec_creditcard_widget@</td>
	      <td>
		<center>
		  <input type="submit" value="Submit">
		</center>
	      </td>
	    </tr>
	    <tr>
	      <td>Expires:</td>
	      <td>@ec_expires_widget@</td>
	    </tr>
	  </table>
	</form>
      </td>
    </tr>
  </table>

</blockquote>
