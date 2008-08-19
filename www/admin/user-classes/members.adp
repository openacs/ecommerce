<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<if @users_count@ gt 0>
<ul>
  @users_in_ec_user_class_html;noquote@
</ul>
</if><else>
  <p>There are no users in this user class.</p>
</else>
