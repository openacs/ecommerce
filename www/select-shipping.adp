<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>

  <property name="signatory">@ec_system_owner;noquote@</property>

  <include src="/packages/ecommerce/lib/checkout-progress" step="3">

<p><b>Choose one</b><p>

<form method="post" action="@form_action@">
  <ol>
    @shipping_options;noquote@
  </ol>

  <center>
    <input type="submit" value="Continue">
  </center>
</form>
