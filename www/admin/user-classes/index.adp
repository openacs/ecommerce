<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<h3>Current User Classes</h3>
<if @uc_info_lines_count@ gt 0>
  <ul>
    @uc_info_lines_html;noquote@
  </ul>
</if><else>
  <p>No user classes exist.</p>
</else>
<br>

<h3>Actions</h3>
<form method=post action=add>
<ul>
  <li><b>Add a New User Class</b> Name: <input type=text name=user_class_name size=30>
    <input type=submit value="Add"></li>
  <li><a href="@audit_url_html;noquote@">Audit All User Classes</a>
</ul>
</form>

