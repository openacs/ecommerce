<table width="100%">
  <tbody>
    <tr>
      <td>@ec_search_widget@</td>
      <td align="right">
	<if @gift_certificates_are_allowed@ true and @current_location@ ne "gift-certificate">
	  [&nbsp;<a href="gift-certificate-order">Order a Gift Certificate</a>&nbsp;]
	</if>
	<if @current_location@ ne "shopping-cart">
	  [&nbsp;<a href="@ec_cart_link@" title="View the contents of your shopping cart">Shopping Cart</a>&nbsp;]
	</if>
	<if @current_location@ ne "your-account">
	  [&nbsp;<a href="@ec_account_link@" title="View your @ec_system_name@ account">Your Account</a>&nbsp;]
	</if>
      </td>
    </tr>
  </tbody>
</table>
<p>
	
