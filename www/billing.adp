<master>
  <property name="title">Completing Your Order</property>
  <property name="context_bar">@context_bar;noquote@</property>
  <property name="signatory">@ec_system_owner;noquote@</property>

  <include src="checkout-progress" step="4">

<h2>Select Your Billing Address</h2>

<blockquote>

  <p><b>Please choose your billing address.</b></p>

  <blockquote>
    <table>
      <if @billing_addresses:rowcount@ ne 0>
	<p>You can select an address listed below or enter a new address.</p>
	<multiple name="billing_addresses">
	  <if @billing_addresses.rownum@ odd>
	    <tr>
	  </if>
	  <else>
	    <tr bgcolor="#eeeeee">
	  </else>
	  <td>
	    @billing_addresses.formatted@
	  </td>
	  <td>
	    <table>
	      <tr>
		<td>
		  <form method="post" action="payment">
		    @billing_addresses.use@
		    <input type="submit" value="Use"></input>
		  </form>
		</td>
		<td>
		  <form method="post" action="address">
		    @billing_addresses.edit@
		    <input type="submit" value="Edit"></input>
		  </form>
		</td>
		<td>
		  <form method="post" action="delete-address">
		    @billing_addresses.delete@
		    <input type="submit" value="Delete"></input>
		  </form>
		</td>
	      </tr>
	    </table>
	  </td>
	</tr>
	  <tr>
	    <td>
	      &nbsp;
	    </td>
	  </tr>
	</multiple>
      </if>
      <else>
	<if @shipping_addresses:rowcount@ ne 0>
	  <p>You can select your shipping address listed below or enter a new address.</p>
	  <multiple name="shipping_addresses">
	    <if @shipping_addresses.rownum@ odd>
	      <tr>
	    </if>
	    <else>
	      <tr bgcolor="#eeeeee">
	    </else>
	    <td>
	      @shipping_addresses.formatted@
	    </td>
	    <td>
	      <table>
		<tr>
		  <td>
		    <form method="post" action="payment">
		      <input type="hidden" name="address_type" value="shipping">
			@shipping_addresses.use@
			<input type="submit" value="Use"></input>
		    </form>
		  </td>
		</tr>
	      </table>
	    </td>
	  </tr>
	    <tr>
	      <td>
		&nbsp;
	      </td>
	    </tr>
	  </multiple>
	</if>
      </else>

    </table>
  </blockquote>

  <table>
    <tr>
      <td>
	<form method="post" action="address">
	  @hidden_form_vars@
	  <input type="submit" value="Enter a new U.S. address">
	</form>
      </td>
      <td>
	or
      </td>
      <td>
	<form method="post" action="address-international">
	  @hidden_form_vars@
	  <input type="submit" value="Enter a new INTERNATIONAL address">
	</form>
      </td>
    </tr>
  </table>

</blockquote>
