<master>
  <property name="title">Shipping Method</property>
  <property name="context_bar">@context_bar;noquote@</property>
  <property name="signatory">@ec_system_owner;noquote@</property>

  <include src="checkout-progress" step="3">


<form method="post" action="@form_action@">
  <ol>
    @shipping_options;noquote@
  </ol>

  <center>
    <input type="submit" value="Continue">
  </center>
</form>
