<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<h3>Your Current Settings</h3>

<p>
@shipping_costs_html;noquote@
</p>

<h3>Change Your Settings</h3>

<p>
All prices are in @currency@.  The price should
be written as a decimal number (no special characters like $).  If a
section is not applicable, just leave it blank.
</p>
<p>
We recommend reading <a href="examples">some examples</a> before you fill in this form.
</p>

<form method=post action=edit>
<ol>

<li><b>Set the Base Cost:</b>
<input type=text name=base_shipping_cost size=5 value="@base_shipping_cost@">
The Base Cost is the base amount that everybody has to pay regardless of
what they purchase.  Then additional amounts are added, as specified below.
</li>

<li><b>Set the Per-Item Cost:</b>
If the "Shipping Price" field of a product is filled in, that will 
override any of the settings below.  Also, you can fill in the
"Shipping Price - Additional" field if you want to charge the
customer a lower shipping amount if they order more than one of the
same product.  (If "Shipping Price - Additional" is blank, they'll
just be charged "Shipping Price" for each item).
<ul>
If the "Shipping Price" field is blank, charge them by one of
these methods <b>(fill in only one)</b>:
  <li>Default Amount Per Item:
  <input type=text name=default_shipping_per_item size=5 value="@default_shipping_per_item@"></li>
  <li>Weight Charge: <input type=text size=5 name=weight_shipping_cost value="@weight_shipping_cost@">
@currency@ / @weight_unit@
  </ul></li>

<li><b>Set the Express Shipping Charges:</b>
Ignore this section if you do not do express shipping.  The amounts you specify below will be <b>added to</b> the amounts you set above if the user elects to have their order express shipped.
  <ul>
  <li>Additional Base Cost: <input type=text name=add_exp_base_shipping_cost size=5 value="@add_exp_base_shipping_cost@"></li>
  <li>Additional Amount Per Item: <input type=text name=add_exp_amount_per_item size=5 value="@add_exp_amount_per_item@"></li>
</ul></li>

<li>Additional Amount by Weight: 
<input type=text name=add_exp_amount_by_weight size=5 value="@add_exp_amount_by_weight@">
@currency@ / @weight_unit@</li>

</ol>

<center>
  <input type=submit value="Submit Changes">
</center>
</form>

<h3>Audit Trail</h3>
<ul>
  <li><a href="@audit_url_html;noquote@">Audit Shipping Costs</a>
</ul>
