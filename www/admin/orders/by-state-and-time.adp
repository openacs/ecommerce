<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

    <form method=post action=by-state-and-time>
@export_form_vars_html;noquote@
      <table border=0 cellspacing=0 cellpadding=0 width=100%>
        <tr bgcolor=#ececec>
	  <td align=center><b>Basket (Order) State</b></td>
          <td align=center><b>In Basket Date</b></td>
        </tr>
        <tr>
          <td align=center><select name=view_order_state>
@order_state_list_html;noquote@
      </select>
      <input type=submit value="Change">
    </td>
    <td align=center>
@linked_confirmed_list_html;noquote@
        </td>
      </tr>
    </table>
   </form>
   <blockquote>
@orders_select_html;noquote@
   </blockquote>
