<master src="default-ec-master">
<property name="title">Completing Your Order</property>
<property name="navbar">checkout {Select Shipping Method}</property>

<h2>Select Your Shipping Method</h2>

<form method="post" action="@form_action@">
  <ol>
    @shipping_options@
  </ol>

  <center>
    <input type="submit" value="Continue">
  </center>
</form>