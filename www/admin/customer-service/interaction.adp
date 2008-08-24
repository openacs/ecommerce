<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<table>
  <tr><td align=right><b>Customer</td><td>@user_id_summary_html;noquote@</td></tr>
  <tr><td align=right><b>Interaction Date</td><td>@interaction_date_html;noquote@</td></tr>
  <tr><td align=right><b>Rep</td><td>@rep_html;noquote@</td></tr>
  <tr><td align=right><b>Originator</td><td>@interaction_originator@</td></tr>
  <tr><td align=right><b>Inquired Via</td><td>@interaction_type@</td></tr>

<if @interaction_headers@ not nil>
  <tr><td align=right><b>Interaction Header</td><td>@interaction_headers;noquote@</td></tr>
</if>

</table>

<br>

<h3>All actions associated with this interaction</h3>
<center>
@interaction_actions_html;noquote@
</center>
