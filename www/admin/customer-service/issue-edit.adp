<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<p>@confirm_user_html;noquote@</p>

<form method=post action=issue-edit-2>
 @export_form_vars_html;noquote@
 <p>Modify Issue Type: @issue_type_widget_html;noquote@</p>
 <center>
  <input type=submit value="Submit Changes">
 </center>
</form>
