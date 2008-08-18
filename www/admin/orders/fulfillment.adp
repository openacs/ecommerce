<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<p>
These <a href=\"fulfillment-items-needed\">items</a> are needed in
order to fulfill all outstanding orders.
</p><p>
Note: Orders over 28 days old cannot be fulfilled through shopping cart, because gateways usually drop the transaction_id associated with the order.
</p>
@orders_select_html;noquote@
