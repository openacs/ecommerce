<master>
  <property name="title">Thank You For Your Order</property>
  <property name="context_bar">@context_bar@</property>
  <property name="signatory">@ec_system_owner@</property>

  <include src="checkout-progress" step="6">

<blockquote>
  <p><b>Please print this page for your records</b></p>
  @order_summary@
</blockquote>
