<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>

<!-- following from billing.adp -->

  <p>To complete your order, submit this form, and confirm the information
    on the following page.</p>

<if @more_addresses_available@ true>
  <p>Alternately, you can use a <a href="checkout">multi-page order process</a>, 
  if you prefer using some of your other addresses on file with us.
  </p>
</if>

<!-- shipping detail -->
<!--   from address.adp  -->
<p>1. Please review your order list for accuracy.</p>
<h3>Order list</h3>
 @items_ul;noquote@
<hr>
<p>2. Complete this information below, or view other <a href="http://kingsolar.com/order.html">ways of ordering</a> from King Solar.</p>

<table border="0" bgcolor="#eeeeee"><form method="post" action="checkout-one-form-2">
@hidden_vars;noquote@
<tr><td colspan="2"><h2>Bill to:</h2></td>
<if @shipping_required@ true><td bgcolor="#ffffff">&nbsp;</td><td colspan="2"><h2>Ship to (if different):</h2></td> </if>
</tr><tr>

<td align="right">First name(s):</td><td><input type="text" name="bill_to_first_names" size="27" value="@bill_to_first_names@" tabindex="1"></td>
<if @shipping_required@ true><td bgcolor="#ffffff">&nbsp;</td><td align="right">First name(s):</td><td><input type="text" name="ship_to_first_names" size="27" value="@ship_to_first_names@" tabindex="21"></td></if>
</tr><tr>

<td align="right">Last name:</td><td><input type="text" name="bill_to_last_name" size="27" value="@bill_to_last_name@" tabindex="2"></td>
<if @shipping_required@ true><td bgcolor="#ffffff">&nbsp;</td><td align="right">Last name:</td><td><input type="text" name="ship_to_last_name" size="27" value="@ship_to_last_name@" tabindex="22"></td></if>
</tr><tr>

<td align="right">Telephone:</td><td><input type="text" name="bill_to_phone" size="20" value="@bill_to_phone@" tabindex="3"></td>
<if @shipping_required@ true><td bgcolor="#ffffff">&nbsp;</td><td align="right">Telephone:</td><td><input type="text" name="ship_to_phone" size="20" value="@ship_to_phone@" tabindex="23"></td></if>
</tr><tr>

<td align="right">Best time to call:</td><td> <input type="radio" tabindex="4" name="bill_to_phone_time" value="d"<if @bill_to_phone_time@ nil or @bill_to_phone_time@ not eq "e"> checked</if>>day&nbsp;&nbsp;&nbsp;<input type="radio" name="bill_to_phone_time" tabindex="4" value="e"<if @bill_to_phone_time@ not nil and @bill_to_phone_time@ eq "e"> checked</if>>evening</td>
<if @shipping_required@ true><td bgcolor="#ffffff">&nbsp;</td><td align="right">Best time to call:</td><td> <input type="radio" name="ship_to_phone_time" tabindex="24" value="d"<if @ship_to_phone_time@ nil or @ship_to_phone_time@ not eq "e"> checked</if>>day&nbsp;&nbsp;&nbsp;<input type="radio" name="ship_to_phone_time" tabindex="24" value="e"<if @ship_to_phone_time@ not nil and @ship_to_phone_time@ eq "e"> checked</if>>evening</td></if>
</tr><tr>
           
<td align="right">Address:</td><td><input type="text" name="bill_to_line1" size="27" value="@bill_to_line1@" tabindex="5"></td>
<if @shipping_required@ true><td bgcolor="#ffffff">&nbsp;</td><td align="right">Address:</td><td><input type="text" name="ship_to_line1" size="27" value="@ship_to_line1@" tabindex="25"></td></if>
</tr><tr>

<td align="right">Address line 2<br>(optional):</td><td><input type="text" name="bill_to_line2" size="27" value="@bill_to_line2@" tabindex="6"></td>
<if @shipping_required@ true><td bgcolor="#ffffff">&nbsp;</td><td align="right">Address line 2<br>(optional):</td><td><input type="text" name="ship_to_line2" size="27" value="@ship_to_line2@" tabindex="26"></td></if>
</tr><tr>

<td align="right">City:</td><td><input type="text" name="bill_to_city" size="20" value="@bill_to_city@" tabindex="7"></td>
<if @shipping_required@ true><td bgcolor="#ffffff">&nbsp;</td><td align="right">City:</td><td><input type="text" name="ship_to_city" size="20" value="@ship_to_city@" tabindex="27"></td></if>
</tr><tr>

<td align="right">State/Province:</td><td>@bill_to_state_widget;noquote@</td>
<if @shipping_required@ true><td bgcolor="#ffffff">&nbsp;</td><td align="right">State/Province:</td><td>@ship_to_state_widget;noquote@</td></if>
</tr><tr>

<td align="right">Other province or region:</td><td><input type="text" name="bill_to_full_state_name" size="20" value="@bill_to_full_state_name@" tabindex="8"></td>
<if @shipping_required@ true><td bgcolor="#ffffff">&nbsp;</td><td align="right">Other province or region:</td><td><input type="text" name="ship_to_full_state_name" size="20" value="@ship_to_full_state_name@" tabindex="28"></td></if>
</tr><tr>

<td align="right">ZIP/Postal code:</td><td><input type="text" name="bill_to_zip_code" size="10" maxlength="10" value="@bill_to_zip_code@" tabindex="9"></td>
<if @shipping_required@ true><td bgcolor="#ffffff">&nbsp;</td><td align="right">ZIP/Postal code:</td><td><input type="text" name="ship_to_zip_code" size="10" maxlength="10" value="@ship_to_zip_code@" tabindex="29"></td></if>
</tr><tr>

<td colspan="2">Country:<br>@bill_to_country_code;noquote@</td>
<if @shipping_required@ true><td bgcolor="#ffffff">&nbsp;</td><td colspan="2">Country:<br>@ship_to_country_code;noquote@</td></if>
</tr>
 <tr><td colspan="2">
   @tax_exempt_options;noquote@
  </td>
  <td bgcolor="#ffffff">&nbsp;</td>
 <td colspan="2">&nbsp;</td></tr>
</table>
<if @shipping_required@ true>
<table border="0" width="75%"> <tr>
  <td>
  <!-- gather shipping method info -->
<h2>Shipping information</h2>
<!-- consider adding a summary of your shipping policy here -->
    @shipping_options;noquote@
 </td></tr></table>
</if>


<! -- following from payment.adp --->

<h2>Payment information</h2>
<table border="0" width="60%"><tr><td>
<if @tax_exempt_status@ true>
    @tax_exempt_options;noquote@
</if>
<if @gift_certificate_covers_whole_order@ true> 
  <p>Your gift certificate balance covers the total cost of your
  order. No need to enter any payment information!</p>
</if>
<else>
  <if @gift_certificate_covers_part_of_order@ true>
    <p>Your gift certificate balance takes care of
     @certificate_amount@ of your order! Please enter credit card
     information to pay for the rest.</p>
  </if>
</else>

<if @gift_certificate_covers_whole_order@ false>
  <if @gift_certificate_p@>
    <p>If you've received a gift certificate, enter the<br>
      Claim Check: <input type="text" name="claim_check" size="20" maxlength="30" tabindex="40"><br>
      to put the funds into your gift certificate account.
    </p>
    <p>If you've entered it before, the funds are already in your account.</p>
  </if>
</if>

</td></tr></table>

<if @gift_certificate_covers_whole_order@ false>
  
  <if @customer_can_use_old_credit_cards@ true>
    <p>Since we already have a credit card on file for you, you
    can just click on the button next to it to use it for this
    order.</p>
    <p>@old_cards_to_choose_from;noquote@</p>
    <p><b>Or enter a new credit card:</b></p>
    <p>If you're using a new card, please enter the full credit card number below.</p>
  </if>
  <table border="0">
  <if @customer_can_use_old_credit_cards@ false>
    <tr><td colspan="2"><p><b>Credit card information</b></p></td></tr>
  </if>
   <tr>
    <td align="right">Credit card number:</td>
    <td><input type="text" name="creditcard_number" size="21" tabindex="41"></td>
   </tr>
   <tr>
    <td align="right">Type:</td>
    <td>@ec_creditcard_widget;noquote@</td>
  </tr>
  <tr>
    <td align="right">Expires:</td>
    <td>@ec_expires_widget;noquote@</td>
  </tr>
<if @ask_for_card_code@ true>
  <tr>
    <td align="right">Card Security Code (cvv2/cvc2/cid):</td>
    <td><input type="text" name="card_code" size="4" tabindex="42"</td>
  </tr>
</if>
  </table>
</if>

 <p align="center"><input type="submit" value="Continue"></p>

  </form>

