<master>
  <property name="title">@title@</property>
  <property name="context_bar">@context_bar@</property>
  <property name="signatory">@ec_system_owner@</property>

  <include src="checkout-progress" step="5">

    <blockquote>
      <if @certificate_added_p@>
	<p><%= [ec_pretty_price @amount@] %> has been added to your gift
	  certificate account!</p>
      </if>
      <else>
	<p>Your gift certificate has already been claimed.  Either you
	  hit submit twice on the form, or it was claimed previously.
	  Once you claim it, it goes into your gift certificate balance
	  and you don't have to claim it again.</p>
      </else>
      <p><a href="payment?address_id=@address_id@">Continue with your
	order</a></p>
    </blockquote>
    
