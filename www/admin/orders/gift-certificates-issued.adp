<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<form method=post action=gift-certificates-issued>
  <table border=0 cellspacing=0 cellpadding=0 width=100%>
    <tr bgcolor=ececec>
      <td align=center><b>Rep</b></td>
      <td align=center><b>Issue Date</b></td>
    </tr>
    <tr>
      <td align=center>
          <select name=view_rep>
            <option value="all">All</option>
            @customer_service_reps_select_html;noquote@
          </select>
          <input type=submit value="Change">
      </td>
      <td align=center>
        @linked_issue_date_list_html;noquote@
      </td>
    </tr>
  </table>
</form>

<if @row_counter@ gt 0>
  <table>
    <tr>
      @header_html;noquote
    </tr>
    @gift_certificates_select_html;noquote@
  </table>
</if><else>
  <center><p>None found.</p></center>
</else>
