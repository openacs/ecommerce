 <if @gift_certificates_are_allowed@ true and @current_location@ ne "gift-certificate"> 
    [&nbsp;<a href="@ec_gift_cert_order_link@">gift certificates</a>&nbsp;] 
 </if>
 <if @current_location@ ne "shopping-cart"> 
  <if @use_paypal_shopping_cart_p@ true>
    [&nbsp;
<form name="_xclick" target="paypal" action="https://www.paypal.com/us/cgi-bin/webscr" method="post">
<input type="hidden" name="cmd" value="_cart">
<input type="hidden" name="business" value="@paypal_business_ref@">
<input type="image" src="https://www.paypal.com/en_US/i/btn/view_cart_new.gif" border="0" name="submit" alt="Make payments with PayPal - it's fast, free and secure!">
<input type="hidden" name="display" value="1">
</form>
 &nbsp;]
  </if><else>
    [&nbsp;<a href="@ec_cart_link@" title="View the contents of your shopping cart">shopping cart</a>&nbsp;]
  </else>
 </if>
 <if @current_location@ ne "your-account"> 
    [&nbsp;<a href="@ec_account_link@" title="View your @ec_system_name@ account">your @ec_system_name@ account</a>&nbsp;]
 </if>
<include src="contextbar">
