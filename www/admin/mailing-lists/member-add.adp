<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

 <if @last_name_p;literal@ true>
  <h3>Users whose last name contains '@last_name@':</h3>
</if><else>
  <h3>Users whose email contains '@email@':</h3>
</else>
<if @user_counter@ gt 0>
  <ul>
    @user_info_html;noquote@
  </ul>
  <p>Click on a name to add user to the mailing list.</p>
</if><else>
  <p>No users found.</p>
</else>

