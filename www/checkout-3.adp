<master>
  <property name="title">Completing Your Order</property>
  <property name="context_bar">@context_bar@</property>
  <property name="signatory">@ec_system_owner@</property>

  <include src="checkout-progress" step="6">

<h2>Please Confirm Your Order</h2>

<blockquote>

  <form method="post" action="finalize-order">
    <p><b>Push Submit to send us your order!</b>
    <input type="submit" value="Submit"></p>

    @order_summary@

    <p><b>Push Submit to send us your order!</b>
    <input type="submit" value="Submit"></p>
  </form>

</blockquote>
