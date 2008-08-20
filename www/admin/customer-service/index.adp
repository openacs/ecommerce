<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<table border="1" cellspacing="0" cellpadding="2">
<tr><td><b>type</b></td><td><b>open</b></td><td><b>closed</b></td></tr>
<tr><td align="right">uncategorized</td>
<if @num_open_issues@ gt 0>
 <td><a href="issues">@num_open_issues@ open</a> </td><td><a href="issues?view_status=closed">closed</a></td></tr>
 @issue_type_list_html;noquote@
</if><else>
 <td><a href="issues">none</a></td><td><a href="issues?view_status=closed">closed</a></td></tr>
</else>

</table><p>Add <a href="interaction-add">New Interaction</a>.</p>
<if @issue_type_list_len@ eq 0>
<p>To see issues separated out by commonly used issue-types, add those issue-types to the "Issue Type" in <a href="picklists">Picklist Management</a>.</p>
</if>

<h3>Search for customer</h3>

<form method=get action=@action_url_html;noquote@>
<p><input type=hidden name=target value="one.tcl">
Search for <b>registered</b> users: <input type=text size=15 name=keyword></p>
</form>

<form method=post action=user-identification-search>
<p>Search for <b>unregistered</b> users with a customer service history:
<input type=text size=15 name=keyword></p>
</form>

<form method=post action=customer-search>
<p>Customers who have spent over
<input type=text size=5 name=amount>
(@currency@) in the last <input type=text size=2 name=days> days.
<input type=submit value="Go"></p>
</form>


<h3>Administrative Actions</h3>
<ul>
<li><a href="spam">Spam Users</a></li>
<li><a href="picklists">Picklist Management</a></li>
<li><a href="canned-responses">Prepared Responses</a></li>
<li><a href="statistics">Statistics and Reports</a></li>
</ul>

