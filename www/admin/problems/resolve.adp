<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<p>Confirm that the problem is resolved.</p>

<form method=post action="resolve-2">
  @export_form_vars_html;noquote@
  <p>
  @problem_date_html;noquote@
  </p><p>
  @problem_details@
 <center>
  <input type=submit value="Problem is resolved">
 </center>
</form>
