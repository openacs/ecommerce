<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<p>We ask you to list the variables you're using so that programmers will know what things they should substitute for in the body of the email.  Variable names should be descriptive so that it's obvious to the programmers what each one means.
</p><p>
An example:
</p>
<table border=0 cellspacing=0 cellpadding=15>
<tr>
<td valign=top align=right><b>Title</td>
<td valign=top>New Order</td>
</tr>
<tr>
<td valign=top align=right><b>Variables</td>
<td valign=top>confirmed_date_here, address_here, order_summary_here, price_here, shipping_here, tax_here, total_here</td>
</tr>
<tr>
<td valign=top align=right><b>When Sent</td>
<td valign=top>This email will automatically be sent out after an order has been authorized</td>
</tr>
<tr>
<td valign=top align=right><b>Subject Line</td>
<td valign=top>Your Order</td>
</tr>
<tr>
<td valign=top align=right><b>Message</td>
<td valign=top>@example_email;noquote@</td>
</tr>
<tr>
<td valign=top align=right><b>Issue Type</td>
<td valign=top>new order</td>
</tr>
</table>
