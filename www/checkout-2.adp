<master>
  <property name="title">Completing Your Order: Verify shopping cart contents</property>
  <property name="context_bar">@context_bar;noquote@</property>
  <property name="signatory">@ec_system_owner;noquote@</property>

  <include src="checkout-progress" step="2">

<blockquote>

  <p>Please verify that the items and quantities shown below are correct. Put a 0 (zero) in the
    Quantity field to remove a particular item from your order. </p>

  <form method="post" action="@form_action@">

    <table>
      <tr>
	<th align="left">Quantity</th>
	<th align="left">Item</th>
      </tr>
      @rows_of_items;noquote@
    </table>
    
    <p>@tax_exempt_options;noquote@</p>

    <center><input type="submit" value="Continue"></center>

  </form>
 </blockquote>
