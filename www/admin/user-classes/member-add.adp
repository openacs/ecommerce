<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<if @last_name_search_p@ true>
  <h3>Users whose last name contains '@last_name@':</h3>
</if><else>
  <h3>Users whose email contains '@email@':</h3>
</else>

<if @users_count@ gt 0>
  <ul>
    @users_select_html;noquote@
  </ul>
  <p>Click on a name to add that user to $user_class_name.</p>
</if><else>
  <p>No users were found.</p>
</else>
