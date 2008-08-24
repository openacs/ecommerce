<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<if @user_counter@ gt 0>
 <ul>
  @users_like_kw_html;noquote@
 </ul>
</if><else>
 <p>No users matching '@keyword@' found.</p>
</else>
