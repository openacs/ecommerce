<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<form method=post action=items-add-4>
@export_form_vars_html;noquote@
<p>This is the price that this user would normally receive for this product. Make modifications as needed:</p>
 <input type=text name=price_name value="@price_name@" size=15>
 <input type=text name=price_charged value="@price_charged;noquote@" size=4> (@currency@)

 <center>
  <input type=submit value="Add the Item">
 </center>
</form>
