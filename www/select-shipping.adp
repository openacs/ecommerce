<master>
  <property name="title">Completing Your Order</property>
  <property name="context_bar">@context_bar@</property>
  <property name="signatory">@ec_system_owner@</property>

  <include src="checkout-progress" step="3">


<h2>Select Your Shipping Method</h2>

<form method="post" action="@form_action@">
  <ol>
    @shipping_options@
  </ol>

  <center>
    <input type="submit" value="Continue">
  </center>
</form>
