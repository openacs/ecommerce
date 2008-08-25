<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<p>The following users will be spammed:</p>
<ul>
 @users_for_spam_html;noquote@
</ul>

<form method=post action=../tools/spell>
 @form_action_html;noquote@
 <table border=0 cellspacing=0 cellpadding=10>
  <tr><td>From</td><td>@customer_service_email@</td></tr>
  <tr><td>Subject Line</td><td><input type=text name=subject size=30></td></tr>
  <tr><td valign=top>Message</td><td><textarea wrap=hard name=message cols=50 rows=35></textarea></td></tr>
  <tr><td>Gift Certificate*</td><td>Amount <input type=text name=amount size=5> (@currency@) &nbsp; &nbsp; Expires @expires_html@</td></tr>
  <tr><td valign=top>Issue Type**</td><td valign=top>@issue_type_widget_html;noquote@</td></tr>
 </table>
 <br>
 <center>
  <input type=submit value="Send">
 </center>
</form>
<p><b>Notes:</b></p>
<p>* You can issue a gift certificate to each user you are spamming (if you don't want to, just leave the amount blank).</p>
<p>** A customer service issue is created whenever an email is
sent. The issue is automatically closed unless the customer replies to
the issue, in which case it should be reopened.</p>
