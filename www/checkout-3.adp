<master src="default-ec-master">
<property name="title">Please Confirm Your Order</property>
<property name="navbar">checkout {Confirm Order}</property>

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
