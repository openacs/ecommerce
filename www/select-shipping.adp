<master>
  <property name="title">Completing Your Order: Shipping Method</property>
  <property name="context_bar">@context_bar;noquote@</property>
  <property name="signatory">@ec_system_owner;noquote@</property>

  <include src="checkout-progress" step="3">

<p><b>Choose one</b><p>

<form method="post" action="@form_action@">
  <ol>
    @shipping_options;noquote@
  </ol>

  <center>
    <input type="submit" value="Continue">
  </center>
</form>
