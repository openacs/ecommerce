<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
  <property name="signatory">@ec_system_owner;noquote@</property>

  <include src="/packages/ecommerce/lib/checkout-progress" step="6">

<h2>Sorry, There seems to be a problem with completing this transaction.</h3>


  
  <p>At this time we are unable to receive authorization to charge
    your credit card.  Please check the number and the expiration
    date and try again or use a different credit card.</p>
<p>If this message persists, there may be a temporary problem, 
   such as the system not being able to reach the merchant banking system.
   Try again later, or report this problem to @ec_system_owner;noquote@.
</p>

	@formatted_address@

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

	<form method="post" action="credit-card-correction-2">
	  <input type="hidden" name="address_id" value="@address_id@"></input>
	  <table>
	    <tr>
	      <td>Credit card number:</td>
	      <td><input type="text" name="creditcard_number" size="21" value="@creditcard_number@"></td>
	    </tr>
	    <tr>
	      <td>Type:</td>
	      <td>@ec_creditcard_widget;noquote@</td>
	    </tr>
	    <tr>
	      <td>Credit card security code (cvv2/cvc2/cid):</td>
	      <td><input type="text" name="card_code" size="4" value="@card_code@"></td>
	    </tr>

	    <tr>
	      <td>Expires:</td>
	      <td>@ec_expires_widget;noquote@</td>
	    </tr>
        <tr>
	      <td colspan="2">
		<center>
		  <input type="submit" value="Submit">
		</center>
	      </td>
        </tr>
	  </table>
	</form>
