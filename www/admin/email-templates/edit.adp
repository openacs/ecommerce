<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<form method=post action="edit-2">
<h3>For informational purposes</h3>

<table noborder>
<tr><td>Title</td><td><input type=text name=title size=30 value="@title@"></td></tr>
<tr><td>Variables</td><td><input type=text name=variables size=30 value="@variables@"> <a href="variables">Note on variables</a></td></tr>
<tr><td>When Sent</td><td><textarea wrap=hard name=when_sent cols=50 rows=3>@when_sent@</textarea></td></tr>
</table>
<br>
<h3>Actually used when sending email</h3>
<table noborder>
<tr><td>Template ID</td><td>@email_template_id@</td></tr>
<tr><td>Subject Line</td><td><input type=text name=subject size=30 value="@subject@"></td></tr>
<tr><td valign=top>Message</td><td><TEXTAREA wrap=hard name=message cols=50 rows=15>@message@</TEXTAREA></td></tr>
<tr><td valign=top>Issue Type*</td><td valign=top>@issue_type_widget_html;noquote</td></tr>
</table>
<br>
<center>
  <input type=submit value="Continue">
</center>
</form>
<p>
* Note: A customer service issue is created whenever an email is sent. The issue is automatically closed unless the customer replies to the issue, in which case it is reopened.
</p>
<p><a href="@audit_url_html;noquote@">Audit Trail</a></p>
