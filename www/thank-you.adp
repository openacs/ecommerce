<master>
  <property name="doc(title)">@title@</property>
  <property name="context">@context;noquote@</property>
  <property name="signatory">@ec_system_owner;noquote@</property>

  <include src="/packages/ecommerce/lib/checkout-progress" step="6">

<blockquote>
  <p><b>Please print this page for your records</b></p>
  @order_summary;noquote@
</blockquote>
