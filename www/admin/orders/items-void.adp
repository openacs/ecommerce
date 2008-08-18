<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<if @n_shipped_items@ gt 0>
 <p><b>Warning:</b> our records show that at least one of these
 items has already shipped, which means that the customer has already
 been charged (for shipped items only). Voiding an item will not cause
 the customer's credit card to be refunded 
 (you can only do that by marking it "received back").</p>
</if>

<if @item_state_done@ true>
 <p><b>Warning:</b> our records show that this item has already
 shipped, which means that the customer has already been charged for this
 item. Voiding an item will not cause the customer's credit card to be
 refunded (you can only do that by marking it "received back").</p>
</if>

<form method=post action=items-void-2>
@export_form_vars_html;noquote@
<if n_items eq 1>
   @order_products_select_html;noquote@
</if><else>
	<p>Please check off the item(s) you wish to void.</p>
	<table>
	  <tr>
	    <th>Void Item</th>
            <th>Product</th>
	    <th>Item State</th>
      </tr>
@order_products_select_html;noquote@
    </table>
</else>
<center>
  <input type=submit value="Confirm">
</center>
</form>
