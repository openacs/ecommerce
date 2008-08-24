<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<p>Please confirm that you want to permanently make this match.  <b>This cannot be undone.</b></p>
<form method=post action=user-identification-match-2>
 @export_form_vars_html;noquote@
 <input type=submit value="Confirm">
</form>
