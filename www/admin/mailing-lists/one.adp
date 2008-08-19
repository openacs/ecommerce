<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<h3>Members</h3>
<if @users_count@ gt 0>
<ul>
  @user_info_html;noquote@
</ul>
</if><else>
<p>None.</p>
</else>
<br>
<h3>Add a Member</h3>
<form method=post action=member-add>
@export_form_vars_html;noquote@
<p>By last name: <input type=text name=last_name size=30>
<input type=submit value="Search"></p>
</form>

<form method=post action=member-add>
@export_form_vars_html;noquote@
<p>By email address: <input type=text name=email size=30>
<input type=submit value="Search"></p>
</form>
