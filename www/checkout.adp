<master>
  <property name="title">Completing Your Order</property>
  <property name="context_bar">@context_bar;noquote@</property>
  <property name="signatory">@ec_system_owner;noquote@</property>

  <include src="checkout-progress" step="1">

<h2>Select Your Shipping Address</h2>

<blockquote>

    <p><b>Please choose your shipping address.</b></p>

    <blockquote>
      <table>
	<if @addresses:rowcount@ ne 0>
	  <p>You can select an address listed below or enter a new address.</p>
	</if>
	<multiple name="addresses">
	  <if @addresses.rownum@ odd>
	    <tr>
	  </if>
	  <else>
	    <tr bgcolor="#eeeeee">
	  </else>
	  <td>
	    @addresses.formatted;noquote@
	  </td>
	  <td>
	    <table>
	      <tr>
		<td>
		  <form method="post" action="checkout-2">
		    @addresses.use;noquote@
		    <input type="submit" value="Use"></input>
		  </form>
		</td>
		<td>
		  <form method="post" action="address">
		    @addresses.edit;noquote@
		    <input type="submit" value="Edit"></input>
		  </form>
		</td>
		<td>
		  <form method="post" action="delete-address">
		    @addresses.delete;noquote@
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
      </table>
    </blockquote>

    <table>
      <tr>
	<td>
	  <form method="post" action="address">
	    @hidden_form_vars;noquote@
	    <input type="submit" value="Enter a new U.S. address">
	  </form>
	</td>
	<td>
	  or
	</td>
	<td>
	  <form method="post" action="address-international">
	    @hidden_form_vars;noquote@
	    <input type="submit" value="Enter a new INTERNATIONAL address">
	  </form>
	</td>
      </tr>
    </table>
   
</blockquote>
