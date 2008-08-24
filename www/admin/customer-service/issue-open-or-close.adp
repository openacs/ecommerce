<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<p>@confirm_user_html;noquote@</p>

<p>Please confirm that you wish to @issue_action;noquote@ this issue.</p>

<form method=post action=issue-open-or-close-2>
 @export_form_vars_html;noquote@
  <center>
   <input type=submit value="Confirm">
  </center>
</form>
