<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

    <ul>
      <li><p><a href="by-order-state-and-time">Orders</a> 
        (@n_o_in_last_24_hours@ in last 24 hours; @n_o_in_last_7_days@ in last 7 days)</p></li>
      <li><p><a href="by-state-and-time">Shopping Basket Activity</a>
        (@s_b_in_last_24_hours@ in last 24 hours; @s_b_in_last_7_days@ in last 7 days)</p></li>
      <li><p><a href="fulfillment">Order Fulfillment</a> 
        @shipping_method_counts_html@</p></li>
      <li><p><a href="gift-certificates">Gift Certificate Purchases</a> 
        (@n_g_in_last_24_hours@ in last 24 hours; @n_g_in_last_7_days@ in last 7 days)</p></li>
      <li><p><a href="gift-certificates-issued">Gift Certificates Issued</a> 
        (@n_gi_in_last_24_hours@ in last 24 hours; @n_gi_in_last_7_days@ in last 7 days)</p></li>
      <li><p><a href="shipments">Shipments</a> 
       (@n_s_in_last_24_hours@ in last 24 hours; @n_s_in_last_7_days@ in last 7 days)</p></li>
      <li><p><a href="refunds">Refunds</a> 
        (@n_r_in_last_24_hours@ in last 24 hours; @n_r_in_last_7_days@ in last 7 days)</p></li>
      <li><p><a href="revenue">Financial Reports</a>
      <li><p>Search for an order:</p>
        <blockquote>
          <form method=post action=search>
            <p>By Order ID: <input type=text name=order_id_query_string size=10></p>
          </form>
          <form method=post action=search>
            <p>By Product SKU: <input type=text name=product_sku_query_string size=30></p>
          </form>
          <form method=post action=search>
            <p>By Product Name: <input type=text name=product_name_query_string size=40></p>
          </form>
          <form method=post action=search>
            <p>By Customer Last Name: <input type=text name=customer_last_name_query_string size=10></p>
          </form>
        </blockquote>
      </li>
    </ul>
