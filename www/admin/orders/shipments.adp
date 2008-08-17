<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

    <table border=0 cellspacing=0 cellpadding=0 width=100%>
    <tr bgcolor=ececec>
      <td align=center><b>Carrier</b></td>
      <td align=center><b>Shipment Date</b></td>
    </tr>
    <tr>
      <td align=center>
     @linked_carrier_list_html;noquote@
    </td>
    <td align=center>
@linked_shipment_date_list_html;noquote@
        </td>
      </tr>
    </table>

    </form>

<if @row_counter@ gt 0>
<table>
@shipments_select_html;noquote@
</table>
</if><else>
<center>None found.</center>
</else>

