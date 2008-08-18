<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<form method=post action=gift-certificates>
  @export_form_vars_html;noquote@
  <table border=0 cellspacing=0 cellpadding=0 width=100%>
    <tr bgcolor=#ececec>
      <td align=center><b>Gift Certificate State</b></td>
      <td align=center><b>Issue Date</b></td>
    </tr>
    <tr>
      <td align=center><select name=view_gift_certificate_state>
        @gift_certificate_state_list_html;noquote@
        </select>
        <input type=submit value=\"Change\"></td>
      <td align=center>@linked_issue_date_list_html;noquote@
          </td>
    </tr>
  </table>
</form>

<if @row_counter@ gt 0>
    <table>
      <tr>
  @table_header_html;noquote@
      </tr>
  @gift_certificates_select_html;noquote@
    </table>
</if><else>
  <center><p>None found.</p></center>
</else>
