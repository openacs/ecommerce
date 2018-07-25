<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>

  <property name="signatory">@ec_system_owner;noquote@</property>

  <include src="/packages/ecommerce/lib/checkout-progress" step="5">

<blockquote>

  <p>Your order will not be complete until you have confirmed the
  total in the next step. <%= [ec_system_name] %> will not charge your
  card without your confirmation of the total.</p>

  <form method="post" action="@form_action@">
    <input type="hidden" name="billing_address_id" value="@billing_address_id@">
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
      <if @gift_certificate_p;literal@ true>
      <p><a href="gift-certificate-claim?address_id=@billing_address_id@">Click here to claim a
      new gift certificate</a></p>
      </if>

      <if @customer_can_use_old_credit_cards@ true>
	<p>Since we already have a credit card on file for you, you
          can just click on the button next to it to use it for this
          order.</p>
	<p>@old_cards_to_choose_from;noquote@</p>
	<p><b>Or enter a new credit card for billing:</b></p>
	<p>If you're using a new card, please enter the full credit card number below.</p>
      </if>
      <table>
	<tr>
	  <td>Credit card number:</td>
	  <td><input type="text" name="creditcard_number" size="21"></td>
	</tr>
	<tr>
	  <td>Type:</td>
	  <td>@ec_creditcard_widget;noquote@</td>
	</tr>
	<tr>
	  <td>Expires:</td>
	  <td>@ec_expires_widget;noquote@</td>
	</tr>
<if @ask_for_card_code@ true>
	<tr>
	  <td>Credit card secrity code (cvv2/cvc2/cid):</td>
	  <td><input type="text" name="card_code" size="4"></td>
	</tr>
</if>
      </table>
    </if>

    <center>
      <input type="submit" value="Continue">
    </center>

  </form>
</blockquote>
