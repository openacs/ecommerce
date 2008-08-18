<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<p>Please confirm that this is correct:</p>

<pre>
@creditcard_type_html;noquote@
@creditcard_number@
exp: @creditcard_expire_1@/@creditcard_expire_2@
</pre>

<form method="post" action="creditcard-add-3">
@export_form_vars_html;noquote@
  <center>
    <input type=submit value="Confirm">
  </center>
</form>
