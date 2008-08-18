<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<p>The following items are needed in order to fulfill all outstanding orders:</p>

<table>
<tr bgcolor="#ececec"><td><b>Quantity</b></td><td><b>SKU</b></td><td><b>Product</b></td></tr>
@items_needed_select_html;noquote@
</table>
