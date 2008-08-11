<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
  <property name="signatory">@ec_system_owner;noquote@</property>

  <property name="current_location">shopping-cart</property>

<include src="/packages/ecommerce/lib/toolbar">
<include src="/packages/ecommerce/lib/searchbar">

<blockquote>
  <if @page_function@ eq "view">
    <form method=post action="shopping-cart-retrieve-3">
      @hidden_form_variables;noquote@
      <input type=submit name=submit value="Retrieve">
      <input type=submit name=submit value="Discard">
    </form>
    <center>
      <p>Saved on @saved_date@</p>
      <table border=0 cellspacing=0 cellpadding=5>
	@shopping_cart_items;noquote@
      </table>
    </center>
    <if @product_counter@ eq 0>
      <p>Your Shopping Cart is empty.</p>
    </if>
  </if>

  <if @page_function@ eq "retrieve">
    <form method=post action="shopping-cart-retrieve-3">
      <%= [export_form_vars order_id] %>
      <p>You currently already have a shopping cart. Would you like to
      merge your current shopping cart with the shopping cart you are
      retrieving, or should the shopping cart you're retrieving
      completely replace your current shopping cart?</p>
      <center>
	<input type=submit name=submit value="Merge">
	<input type=submit name=submit value="Replace">
      </center>
    </form>
  </if>

  <if @page_function@ eq "discard">
    <form method=post action="shopping-cart-retrieve-3">
    @hidden_form_variables;noquote@
    <p>If you discard this shopping cart, it will never be
    retrievable.  Are you sure you want to discard it?</p>
    <center>
	<input type=submit name=submit value="Discard">
	<input type=submit name=submit value="Save it for Later">
      </center>
    </form>
  </if>

  <if @page_function@ eq "invalid_order">
     <p>The order you have selected either does not exist or does not
       belong to you.  Please contact <a href="mailto@ec_system_owner@">@ec_system_owner@</a> 
       if this is incorrect.</p>
  </if>

</blockquote>
