<master>
  <property name="title">Please Confirm Your Gift Certificate Order</property>
  <property name="context_bar">@context_bar;noquote@</property>
  <property name="signatory">@ec_system_owner;noquote@</property>

  <property name="show_toolbar_p">t</property>
  <property name="current_location">gift-certificate</property>

<blockquote>
  <form method="post" action="gift-certificate-finalize-order">
    @hidden_form_variables@
    <b>Push Submit to send us your order!</b> <input type="submit" value="Submit">
      <blockquote>
	<table>
	  <tr>
	    <td valign="top">
	      Your email address:
	    </td>
	    <td>
	      @user_email@<br><br>
	    </td>
	  </tr>
	  <tr>
	    <td colspan="2">
	      <font size="+1">Your Gift Certificate Order:</font>
	    </td>
	  </tr>
	  @to_row@
	  @from_row@
	  @message_row@
	  <tr>
	    <td valign="top">
	      <b>Will be sent to:</b>
	    </td>
	    <td>
	      @recipient_email@<br><br>
	    </td>
	  </tr>
	  <tr>
	    <td>
	      <b>Subtotal:</b>
	    </td>
	    <td>
	      @formatted_amount@
	    </td>
	  </tr>
	  <tr>
	    <td>
	      <b>Shipping:</b>
	    </td>
	    <td>
	      @zero_in_the_correct_currency@
	    </td>
	  </tr>
	  <tr>
	    <td>
	      <b>Tax:</b>
	    </td>
	    <td>
	      @zero_in_the_correct_currency@
	    </td>
	  </tr>
	  <tr>
	    <td>
	      <b>-----------</b>
	    </td>
	    <td>
	      <b>-----------</b>
	    </td>
	  </tr>
	  <tr>
	    <td>
	      <b>Total Due:</b>
	    </td>
	    <td>
	      @formatted_amount@
	    </td>
	  </tr>
	</table>
      </blockquote>
      <b>Push Submit to send us your order!</b> <input type="submit" value="Submit">
  </form>
</blockquote>
