<master src="default-ec-master"></master>

<if @address_type@ eq "shipping">
  <property name="title">Your Shipping Address Has Been Stored</property>
  <property name="navbar">checkout {Select Shipping Address}</property>
  <h2>Your Shipping Address Has Been Stored</h2>
</if>
<else>
  <property name="title">Enter Your Billing Address Has Been Store</property>
  <if @action@ ne "gift-certificate-billing">
    <property name="navbar">checkout {Select Billing Address}</property>
  </if>
  <h2>Your Billing Address Has Been Stored</h2>
</else>

<center>
  <table>
    <tr>
      <td>
	@formatted_address@
      </td>
    </tr>
  </table>

  <p>
    <form method="post" action="@action@">
      @hidden_form_vars@
      <input type="submit" value="Continue">
    </form>
  </p>

</center>
