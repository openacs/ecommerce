<table width="100%" bgcolor="lightgray">
  <tbody>
    <tr>
      <td align="center"><if @step@ ge 1><b></if>Select Shipping Address<if @step@ ge 1></b></if></td>
      <td align="center"><code>---></code></td>
      <td align="center"><if @step@ ge 2><b></if>Verify Order<if @step@ ge 2><b></if></td>
      <td align="center"><code>---></code></td>
      <if @express_shipping_avail_p@>
	<td align="center"><if @step@ ge 3><b></if>Select Shipping Method<if @step@ ge 3><b></if></td>
      <td align="center"><code>---></code></td>
      </if>
      <td align="center"><if @step@ ge 4><b></if>Select Billing Address<if @step@ ge 4><b></if></td>
      <td align="center"><code>---></code></td>
      <td align="center"><if @step@ ge 5><b></if>Enter Payment Info<if @step@ ge 5><b></if></td>
      <td align="center"><code>---></code></td>
      <td align="center"><if @step@ ge 6><b></if>Confirm Order<if @step@ ge 6><b></if></td>
    </tr>
  </tbody>
</table>
