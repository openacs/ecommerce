<master>
  <property name="title">Completing Your Order: Verify and submit order</property>
  <property name="context_bar">@context_bar;noquote@</property>
  <property name="signatory">@ec_system_owner;noquote@</property>

<if @display_progress@ true>
  <include src="checkout-progress" step="6">
</if>

<blockquote>

  <form method="post" action="finalize-order">
    <p><b>Push <input type="submit" value="Submit"> to send us your order!</b>
    </p>

    @order_summary;noquote@

    <p><b>Push <input type="submit" value="Submit"> to send us your order!</b>
    </p>
  </form>

</blockquote>
