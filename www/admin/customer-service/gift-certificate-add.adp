<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<p>Please confirm that you wish to add @price_html;noquote@ to
@user_link;noquote@'s gift certificate account (expires @expiration_to_print@).</p>

<form method=post action=gift-certificate-add-2>
 @export_form_vars_html;noquote@
 <center>
  <input type=submit value="Confirm">
 </center>
</form>
