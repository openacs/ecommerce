<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<p>Customers who spent more than @currency@ in the last @days@ days:</p>
<if @user_id_list_len@ eq 0>
 <p>None found.</p>
</if><else>
 <ul>
  @user_ids_from_search_html;noquote@
 </ul>
 <p><a href="spam-2?show_users_p=t&@export_url_vars_html;noquote@">Email these users</a></p>
</else>
