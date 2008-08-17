<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

    <table border=0 cellspacing=0 cellpadding=0 width=100%>
    <tr>
      <td align=center><b>Refund Date</b></td>
    </tr>
    <tr>
      <td align=center>@linked_refund_date_list_html;noquote@</td>
    </tr>
    </table>

<if @row_counter@ gt 0>
  @table_header;noquote@
    @refunds_select_html;noquote@
  </table>
</if><else>
  <center><p>None found.</p></center>
</esle>
