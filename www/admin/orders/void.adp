<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<p>This action will cause all individual items in this order to be
marked 'void'.</p>

<if @n_shipped_items@ gt 0>
<p><font color=red>Warning:</font> our records show that at least one item in this
    order has already shipped, which means that the customer has already been charged
    (for shipped items only).  
    </p>
</if>

<p>Voiding is usually done if the customer cancels their order before
anything ships.</p>
<p>Voiding an order does not refund the customer's credit card. You can only apply a refund
through the shopping basket by marking individual items "received back").</p>

<form method=post action=void-2>
@export_form_vars_html;noquote@
<p>Please explain why you are voiding this order:</p>
<blockquote>
<textarea name=reason_for_void rows=5 cols=50 wrap>
</textarea>
</blockquote>
<br>
<center>
<input type=submit value="Void It!">
</center>
</form>

