<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
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
