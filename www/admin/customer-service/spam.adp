<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<form method=post action=spam-log>
<p><input type="submit" value="View spam log">
@report_date_range_widget_html;noquote@
</p>
</form>

<ol>
 <li><b>Spam all users in a mailing list:</b> @ml_body;noquote@</li>
 <li><b>Spam all members of a user class:</b> @uc_body;noquote@</li>
 <li><b>Spam all users who bought this product:</b>
  <form method=post action=spam-2>Product SKU: <input type=text name=product_sku size=5><br>
   <input type=checkbox name=show_users_p value="t" checked>Show me the users who will be spammed.</br>
   <center><input type=submit value="Continue"></center></form></li>
  <li><b>Spam all users who viewed this product:</b>
   <form method=post action=spam-2>Product SKU: <input type=text name=viewed_product_sku size=5><br>
    <input type=checkbox name=show_users_p value="t" checked>Show me the users who will be spammed.<br>
    <center><input type=submit value="Continue"></center></form></li>
  <li><b>Spam all users who viewed this category:</b> @c_body;noquote@</li>
  <li><b>Spam all users whose last visit was:</b> 
   <form method=post action=spam-2>@report_date_range_widget_html;noquote@<br>
   <input type=checkbox name=show_users_p value="t" checked>Show me the users who will be spammed.<br>
   <center><input type=submit value="Continue"></center></form></li>
</ol>
