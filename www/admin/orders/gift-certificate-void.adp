<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<p>Please explain why you are voiding this gift certificate:</p>
<form method=post action=gift-certificate-void-2>
  @export_form_vars_html;noquote@
  <textarea wrap name=reason_for_void rows=3 cols=50></textarea>
  <center><input type=submit value="Continue"></center>
</form>
