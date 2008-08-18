<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<form method=post action=items-return-3>
  @export_form_vars_html;noquote@
  <table border=0 cellspacing=0 cellpadding=10>
    <tr>
      <th>Item</th><th>Price to Refund</th><th>Shipping to Refund</th>
    </tr>
    @items_to_print;noquote@
  </table>
  <p>Base shipping charge to refund: 
    <input type=text name=base_shipping_to_refund value="@base_shipping_to_refund@" size="5"> 
    (out of @base_shipping_html@)</p>
  <center><input type=submit value="Continue"></center>
</form>
