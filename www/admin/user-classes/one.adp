<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>


<ul>
<form method=post action=edit>
<li>Change user class name to: <input type=text name=user_class_name size=30 value="@user_class_name@">
<input type=submit value="Change">
</form>

<li><a href="members?@export_form_user_class_id_html;noquote@">View all members of this user class</a></li>

<li><a href="delete?@export_form_user_class_name_id_html;noquote@">Delete this user class</a></li>

<li><a href="@audit_url_html;noquote@">Audit Trail</a></li>

<li>Add a member to this user class.  Search for a member to add<br>
 <form method=post action=member-add>
  @export_form_user_class_name_id_html;noquote@
By last name: <input type=text name=last_name size=30>
<input type=submit value="Search">
</form>

<form method=post action=member-add>
  @export_form_user_class_name_id_html;noquote@
By email address: <input type=text name=email size=30>
<input type=submit value="Search">
</form>
</li>
</ul>
