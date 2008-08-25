<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>


<table>
<tr>
 <td align=right><b>Customer</td>
 <td>@user_id_summary_html;noquote@</td>
</tr>

<if @order_id@ not nil>
 <tr>
  <td align=right><b>Order #</td>
  <td><a href="../orders/one?order_id=@order_id@">@order_id@</a></td>
 </tr>
</if>

<if @issue_type@ not nil>
 <tr>
  <td align=right><b>Issue Type</td>
  <td>@issue_type;noquote@</td>
 </tr>
</if>

<tr>
 <td align=right><b>Open Date</td>
 <td>@open_full_date_html;noquote@</td>
</tr>

<if @close_date@ not nil>
 <tr>
  <td align=right><b>Close Date</td>
  <td>@close_date_html;noquote@</td>
 </tr>
 <tr>
  <td align=right><b>Closed By</td>
  <td><a href="@closed_by_user_id_url@">@closed_rep_name@</a></td>
 </tr>
</if>

</table>
<br>

<h3>All actions associated with this issue</h3>

@actions_assoc_w_user_html;noquote@

